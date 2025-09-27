import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import '../utils/receipt_parser.dart';

class OCRService {
  late TextRecognizer _textRecognizer;
  final ReceiptParser _receiptParser = ReceiptParser();

  OCRService() {
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  }

  Future<Map<String, dynamic>> processReceipt(String imagePath) async {
    try {
      // Preprocess image
      final processedImagePath = await _preprocessImage(imagePath);
      
      // Perform OCR
      final inputImage = InputImage.fromFilePath(processedImagePath);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      // Parse the extracted text
      final parsedData = _receiptParser.parseReceiptText(recognizedText.text);
      
      return {
        'success': true,
        'rawText': recognizedText.text,
        'parsedData': parsedData,
        'confidence': _calculateConfidence(recognizedText),
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'rawText': '',
        'parsedData': null,
      };
    }
  }

  Future<String> _preprocessImage(String imagePath) async {
    try {
      // Load the image
      final imageFile = File(imagePath);
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      
      if (image == null) {
        return imagePath;
      }
      
      // Apply preprocessing
      // 1. Convert to grayscale
      image = img.grayscale(image);
      
      // 2. Adjust contrast
      image = img.adjustColor(image, contrast: 1.5);
      
      // 3. Apply adaptive threshold for better text detection
      image = _adaptiveThreshold(image);
      
      // 4. Remove noise
      image = _removeNoise(image);
      
      // Save processed image
      final processedPath = imagePath.replaceAll('.', '_processed.');
      final processedFile = File(processedPath);
      await processedFile.writeAsBytes(img.encodeJpg(image, quality: 95));
      
      return processedPath;
    } catch (e) {
      print('Image preprocessing failed: $e');
      return imagePath; // Return original if preprocessing fails
    }
  }

  img.Image _adaptiveThreshold(img.Image image) {
    // Simple adaptive thresholding implementation
    final width = image.width;
    final height = image.height;
    
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixel = image.getPixel(x, y);
        final luminance = img.getLuminance(pixel);
        
        // Calculate local mean in a 15x15 window
        int sum = 0;
        int count = 0;
        
        for (int dy = -7; dy <= 7; dy++) {
          for (int dx = -7; dx <= 7; dx++) {
            final nx = x + dx;
            final ny = y + dy;
            
            if (nx >= 0 && nx < width && ny >= 0 && ny < height) {
              sum += img.getLuminance(image.getPixel(nx, ny)).toInt();
              count++;
            }
          }
        }
        
        final localMean = sum / count;
        final threshold = localMean - 15; // Offset for better results
        
        if (luminance < threshold) {
          image.setPixel(x, y, img.ColorInt32.rgb(0, 0, 0));
        } else {
          image.setPixel(x, y, img.ColorInt32.rgb(255, 255, 255));
        }
      }
    }
    
    return image;
  }

  img.Image _removeNoise(img.Image image) {
    // Simple noise removal using median filter
    final width = image.width;
    final height = image.height;
    final output = img.Image(width: width, height: height);
    
    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        List<int> values = [];
        
        // Get 3x3 neighborhood values
        for (int dy = -1; dy <= 1; dy++) {
          for (int dx = -1; dx <= 1; dx++) {
            final pixel = image.getPixel(x + dx, y + dy);
            values.add(img.getLuminance(pixel).toInt());
          }
        }
        
        // Sort and get median
        values.sort();
        final median = values[4]; // Middle value of 9 elements
        
        output.setPixel(x, y, img.ColorInt32.rgb(median, median, median));
      }
    }
    
    return output;
  }

  double _calculateConfidence(RecognizedText recognizedText) {
    if (recognizedText.blocks.isEmpty) {
      return 0.0;
    }
    
    double totalConfidence = 0.0;
    int wordCount = 0;
    
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement element in line.elements) {
          // ML Kit doesn't provide confidence scores directly,
          // so we estimate based on text characteristics
          double elementConfidence = _estimateConfidence(element.text);
          totalConfidence += elementConfidence;
          wordCount++;
        }
      }
    }
    
    return wordCount > 0 ? (totalConfidence / wordCount) : 0.0;
  }

  double _estimateConfidence(String text) {
    // Estimate confidence based on text characteristics
    double confidence = 1.0;
    
    // Reduce confidence for very short text
    if (text.length < 2) {
      confidence *= 0.7;
    }
    
    // Reduce confidence for text with many special characters
    final specialCharRatio = RegExp(r'[^a-zA-Z0-9\s]').allMatches(text).length / text.length;
    if (specialCharRatio > 0.5) {
      confidence *= 0.8;
    }
    
    // Reduce confidence for all uppercase (might be OCR error)
    if (text == text.toUpperCase() && text.length > 3) {
      confidence *= 0.9;
    }
    
    return confidence;
  }

  Future<List<String>> detectTextLines(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      List<String> lines = [];
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          lines.add(line.text);
        }
      }
      
      return lines;
    } catch (e) {
      print('Text detection failed: $e');
      return [];
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}