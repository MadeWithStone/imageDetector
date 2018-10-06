//
//  Copyright (c) 2018 Maxwell Stone.
//


import UIKit
// [START import_vision]
import Firebase
// [END import_vision]

/// Main view controller class.
@objc(ViewController)
class ViewController:  UIViewController, UINavigationControllerDelegate {
  /// Firebase vision instance.
  // [START init_vision]
  lazy var vision = Vision.vision()
  // [END init_vision]

  /// A string holding current results from detection.
  var resultsText = ""
    
    var results: [AnyObject] = []

  /// An overlay view that displays detection annotations.
  private lazy var annotationOverlayView: UIView = {
    precondition(isViewLoaded)
    let annotationOverlayView = UIView(frame: .zero)
    annotationOverlayView.translatesAutoresizingMaskIntoConstraints = false
    return annotationOverlayView
  }()

  /// An image picker for accessing the photo library or camera.
  var imagePicker = UIImagePickerController()
    
  // Image counter.
  var currentImage = 0

  // MARK: - IBOutlets

    @IBOutlet weak var landmarkView: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var photoCameraButton: UIBarButtonItem!
    @IBOutlet weak var infoBtn: UIButton!
    var currentLandmark = Lid(landmarkName: "Detection Has Not Started", confidence: 0, entityId: "loading...", url: "loading...")

  // MARK: - UIViewController
//let hell = URL(string: <#T##String#>)
    override func viewDidAppear(_ animated: Bool) {
        initializeView()
    }
  override func viewDidLoad() {
    super.viewDidLoad()
    
    UINavigationBar.appearance().barTintColor = hexStringToUIColor(hex: "1d2731")
    
    infoBtn.isEnabled = false
    imageView.image = UIImage(named: Constants.images[currentImage])
    imageView.addSubview(annotationOverlayView)
    NSLayoutConstraint.activate([
      annotationOverlayView.topAnchor.constraint(equalTo: imageView.topAnchor),
      annotationOverlayView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
      annotationOverlayView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
      annotationOverlayView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
      ])

    imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
    imagePicker.sourceType = .photoLibrary
    imagePicker.title = "Photos"
    imagePicker.navigationBar.tintColor = hexStringToUIColor(hex: "328CC1")
    

    if !UIImagePickerController.isCameraDeviceAvailable(.front) &&
      !UIImagePickerController.isCameraDeviceAvailable(.rear) {
      photoCameraButton.isEnabled = false
        photoCameraButton.tintColor = hexStringToUIColor(hex: "ob3c5d")
      
    }

    
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.title = " Landmarks the Spot"
    
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    navigationController?.navigationBar.isHidden = false
  }

  // MARK: - IBActions

  @IBAction func detect(_ sender: Any) {
    landmarkView.text = "detecting..."
    clearResults()
    detectCloudLandmarks(image: imageView.image)
    
  }

  @IBAction func openPhotoLibrary(_ sender: Any) {
    imagePicker.sourceType = .photoLibrary
    present(imagePicker, animated: true)
  }
    
    @IBAction func moreInfoSender(sender: Any){
        var urlToload: URL = URL(string: "https://wikipedia.org/wiki/")!
        urlToload = urlToload.appendingPathComponent(currentLandmark.url)
        print(urlToload)
        UIApplication.shared.open(urlToload, options: [:])
        
        //print(results)
    }

  @IBAction func openCamera(_ sender: Any) {
    guard UIImagePickerController.isCameraDeviceAvailable(.front) ||
      UIImagePickerController.isCameraDeviceAvailable(.rear)
      else {
        return
    }
    imagePicker.sourceType = .camera
    present(imagePicker, animated: true)
  }
    
  @IBAction func changeImage(_ sender: Any) {
    clearResults()
    currentImage = (currentImage + 1) % Constants.images.count
    imageView.image = UIImage(named: Constants.images[currentImage])
  }

  // MARK: - Private

  /// Removes the detection annotations from the annotation overlay view.
  private func removeDetectionAnnotations() {
    for annotationView in annotationOverlayView.subviews {
      annotationView.removeFromSuperview()
    }
  }

  /// Clears the results text view and removes any frames that are visible.
  private func clearResults() {
    removeDetectionAnnotations()
    self.resultsText = ""
  }
    
    func initializeView(){
        clearResults()
        landmarkView.text = "Detection Has Not Started"
        infoBtn.isEnabled = false
        infoBtn.setTitleColor(hexStringToUIColor(hex: "ob3c5d"), for: .normal)
    }

  private func showResults() {
    landmarkView.text = "Landmark: \(currentLandmark.landmarkName)"
    infoBtn.isEnabled = true
    infoBtn.setTitleColor(hexStringToUIColor(hex: "328CC1"), for: .normal)
    /*let resultsAlertController = UIAlertController(
      title: "Detection Results",
      message: nil,
      preferredStyle: .actionSheet
    )
    resultsAlertController.addAction(
      UIAlertAction(title: "OK", style: .destructive) { _ in
        resultsAlertController.dismiss(animated: true, completion: nil)
      }
    )
    resultsAlertController.message = resultsText
    present(resultsAlertController, animated: true, completion: nil)
    print(resultsText)*/
  }

  /// Updates the image view with a scaled version of the given image.
  private func updateImageView(with image: UIImage) {
    let orientation = UIApplication.shared.statusBarOrientation
    var scaledImageWidth: CGFloat = 0.0
    var scaledImageHeight: CGFloat = 0.0
    switch orientation {
    case .portrait, .portraitUpsideDown, .unknown:
      scaledImageWidth = imageView.bounds.size.width
      scaledImageHeight = image.size.height * scaledImageWidth / image.size.width
    case .landscapeLeft, .landscapeRight:
      scaledImageWidth = image.size.width * scaledImageHeight / image.size.height
      scaledImageHeight = imageView.bounds.size.height
    }
    DispatchQueue.global(qos: .userInitiated).async {
      // Scale image while maintaining aspect ratio so it displays better in the UIImageView.
      var scaledImage = image.scaledImage(
        withSize: CGSize(width: scaledImageWidth, height: scaledImageHeight)
      )
      scaledImage = scaledImage ?? image
      guard let finalImage = scaledImage else { return }
      DispatchQueue.main.async {
        self.imageView.image = finalImage
      }
    }
  }

  private func transformMatrix() -> CGAffineTransform {
    guard let image = imageView.image else { return CGAffineTransform() }
    let imageViewWidth = imageView.frame.size.width
    let imageViewHeight = imageView.frame.size.height
    let imageWidth = image.size.width
    let imageHeight = image.size.height

    let imageViewAspectRatio = imageViewWidth / imageViewHeight
    let imageAspectRatio = imageWidth / imageHeight
    let scale = (imageViewAspectRatio > imageAspectRatio) ?
      imageViewHeight / imageHeight :
      imageViewWidth / imageWidth

    // Image view's `contentMode` is `scaleAspectFit`, which scales the image to fit the size of the
    // image view by maintaining the aspect ratio. Multiple by `scale` to get image's original size.
    let scaledImageWidth = imageWidth * scale
    let scaledImageHeight = imageHeight * scale
    let xValue = (imageViewWidth - scaledImageWidth) / CGFloat(2.0)
    let yValue = (imageViewHeight - scaledImageHeight) / CGFloat(2.0)

    var transform = CGAffineTransform.identity.translatedBy(x: xValue, y: yValue)
    transform = transform.scaledBy(x: scale, y: scale)
    return transform
  }
    
    //func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    //    dismiss(animated: true, completion: nil)
    //}
  
}


// MARK: - UIImagePickerControllerDelegate

extension ViewController: UIImagePickerControllerDelegate {

  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [String: Any]
    ) {
    clearResults()
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      updateImageView(with: pickedImage)
    }
    dismiss(animated: true)
  }
}


/// Extension of ViewController for On-Device and Cloud detection.
extension ViewController {

  /// Detects landmarks on the specified image and draws a frame around the detected landmarks using
  /// cloud landmark API.
  ///
  /// - Parameter image: The image.
  func detectCloudLandmarks(image: UIImage?) {
    guard let image = image else { return }

    // Define the metadata for the image.
    let imageMetadata = VisionImageMetadata()
    imageMetadata.orientation = UIUtilities.visionImageOrientation(from: image.imageOrientation)

    // Initialize a VisionImage object with the given UIImage.
    let visionImage = VisionImage(image: image)
    visionImage.metadata = imageMetadata

    // Create a landmark detector.
    // [START config_landmark_cloud]
    let options = VisionCloudDetectorOptions()
    options.modelType = .latest
    options.maxResults = 20
    // [END config_landmark_cloud]

    // [START init_landmark_cloud]
    let cloudDetector = vision.cloudLandmarkDetector(options: options)
    // Or, to use the default settings:
    // let cloudDetector = vision.cloudLandmarkDetector()
    // [END init_landmark_cloud]

    // [START detect_landmarks_cloud]
    cloudDetector.detect(in: visionImage) { landmarks, error in
      guard error == nil, let landmarks = landmarks, !landmarks.isEmpty else {
        // [START_EXCLUDE]
        let errorString = error?.localizedDescription ?? Constants.detectionNoResultsMessage
        self.resultsText = "Cloud landmark detection failed with error: \(errorString)"
        self.infoBtn.isEnabled = false
        self.landmarkView.text = "Detection Failed With Error: \(errorString)"
        // [END_EXCLUDE]
        return
      }

      // Recognized landmarks
      // [START_EXCLUDE]
      self.resultsText = landmarks.map { landmark -> String in
        let transformedRect = landmark.frame.applying(self.transformMatrix())
        UIUtilities.addRectangle(
          transformedRect,
          to: self.annotationOverlayView,
          color: self.hexStringToUIColor(hex: "328CC1")
        )
        self.results = [landmark.landmark as AnyObject, landmark.confidence!, landmark.entityId as AnyObject, landmark.frame as AnyObject, landmark.landmark as AnyObject]
        //self.currentLandmark = Lid(landmarkName: landmark.landmark ?? "", confidence: landmark.confidence ?? 0, entityId: landmark.entityId ?? "", url: URL(string: "https://wikipedia.org/wiki/(describing: landmark.landmark)")!)
        print("https://wikipedia.org/wiki/(describing: landmark.landmark)")
        self.currentLandmark = Lid(landmarkData: ["landmarkName": landmark.landmark as AnyObject, "confidence": landmark.confidence!, "entityId": landmark.entityId as AnyObject, "url": landmark.landmark as AnyObject])
        
        print(self.results[4])
        
        return "Landmark: \(String(describing: landmark.landmark ?? "")), " +
          "Confidence: \(String(describing: landmark.confidence ?? 0) ), " +
          "EntityID: \(String(describing: landmark.entityId ?? "") ), " +
        "Frame: \(landmark.frame)"
        }.joined(separator: "\n")
      self.showResults()
      // [END_EXCLUDE]
    }
    // [END detect_landmarks_cloud]
  }

  /// Detects labels on the specified image using cloud label API.
  ///
  /// - Parameter image: The image.
  
  // [END detect_label_cloud]
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

// MARK: - Enums



private enum Constants {
  static let images = ["liberty.jpg"]
  static let modelExtension = "tflite"
  static let localModelName = "mobilenet"
  static let quantizedModelFilename = "mobilenet_quant_v1_224"

  static let detectionNoResultsMessage = "No results returned."
  static let failedToDetectObjectsMessage = "Failed to detect objects in image."

  static let labelConfidenceThreshold: Float = 0.75
  static let smallDotRadius: CGFloat = 5.0
  static let largeDotRadius: CGFloat = 10.0
  static let lineColor = UIColor.yellow.cgColor
    static let fillColor = UIColor.self
}

