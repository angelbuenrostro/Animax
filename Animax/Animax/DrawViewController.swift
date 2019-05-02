//
//  ViewController.swift
//  Animax
//
//  Created by Angel Buenrostro on 4/24/19.
//  Copyright © 2019 Angel Buenrostro. All rights reserved.
//

import UIKit
import Photos

class DrawViewController: UIViewController {
    
    

    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    var isErasing: Bool = false

    @IBOutlet var menuView: UIView!
    @IBOutlet var toolBarView: UIView!
    @IBOutlet weak var exportButton: UIButton!
    @IBOutlet weak var colorWheelButton: UIButton!
    @IBOutlet weak var colorWheel: ColorWheel!
    @IBOutlet weak var colorSwatch: UIButton!
    @IBOutlet weak var optionsButton: UIButton!
    
    @IBOutlet weak var drawView: SwiftyDrawView!
    @IBOutlet weak var eraserButton: UIButton!
    
    
    @IBOutlet weak var brushSizeSlider: UISlider!
    @IBOutlet weak var brushOpacitySlider: UISlider!
    
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var slidersStackView: UIStackView!
    @IBOutlet weak var colorsStackView: UIStackView!
    
    override func viewWillAppear(_ animated: Bool) {
        setupUI()
        //drawView.isMultipleTouchEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if #available(iOS 9.1, *) {
            drawView.allowedTouchTypes = [.finger, .pencil]
        }
    }
    
    func animateMenuView() {
        self.view.addSubview(menuView)
        menuView.center = self.view.center
        menuView.layer.cornerRadius = 20
        menuView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        menuView.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            self.menuView.alpha = 1
            self.menuView.transform = CGAffineTransform.identity
        }
    }

    @IBAction func optionsButtonTapped(_ sender: Any) {
        if !self.view.subviews.contains(menuView){
            animateMenuView()
        } else {
            menuView.removeFromSuperview()
        }
    }
    @IBAction func brushSizeSliderChanged(_ sender: Any) {
        drawView.brush.width = CGFloat(brushSizeSlider.value)
    }
    @IBAction func brushOpacitySliderChanged(_ sender: Any) {
        drawView.brush.opacity = CGFloat(brushOpacitySlider.value)
        colorSwatch.alpha = CGFloat(brushOpacitySlider.value)
    }
    @IBAction func colorChanged(_ sender: ColorWheel) {
        drawView.brush.color = sender.color
        colorSwatch.backgroundColor = sender.color
    }
    @IBAction func colorWheelButtonTapped(_ sender: Any) {
        colorWheel.isHidden = !colorWheel.isHidden
    }
    
    @IBAction func exportButtonTapped(_ sender: Any) {
        
        // Get image from drawView and save to User Photo Library
        
        guard let image = drawView.getImage() else {
            
            //popup view controller saying please draw something first
            let alertController = UIAlertController(title: "Oops", message: "Draw something first!", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true, completion: nil)
            self.menuView.removeFromSuperview()
            return
        }
        
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { (success, error) in
            if success {
                // pop up alert to notify user
                print("successfully saved")
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Saved", message: "Drawing successfully saved to camera roll", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alertController, animated: true, completion: nil)
                    
                    self.menuView.removeFromSuperview()
                }
            } else if let error = error {
                // pop up alert to notify user
            } else {
                fatalError()
            }
        }
        //
        
        print("export tapped")
    }
    
    @IBAction func cancelExportButtonTapped(_ sender: Any) {
        self.menuView.removeFromSuperview()
    }
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        drawView.clear()
    }
    @IBAction func undoButtonTapped(_ sender: Any) {
        drawView.undo()
    }
    @IBAction func redoButtonTapped(_ sender: Any) {
        drawView.redo()
    }
    @IBAction func eraserButtonTapped(_ sender: Any) {
        if !isErasing {
        drawView.brush.blendMode = .clear
            eraserButton.setTitleColor(.black, for: .normal)
            isErasing = true
        } else {
            eraserButton.setTitleColor(#colorLiteral(red: 0.01202730276, green: 0.3897084594, blue: 0.8242080808, alpha: 1), for: .normal)
            isErasing = false
            drawView.brush.blendMode = .normal
        }
    }
    
    func setupUI(){
        self.view.addSubview(toolBarView)
        toolBarView.center = CGPoint(x: 50, y: self.view.center.y)
        
        
        // add Gesture Recognizer
        addPinchGesture(view: drawView)
        
        
        toolBarView.layer.cornerRadius = 20
        slidersStackView.backgroundColor = .black
        slidersStackView.makeVertical()
        optionsButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        var sliderPosition = toolBarView.center
        slidersStackView.center = toolBarView.center
        
        
        colorsStackView.center = CGPoint(x:sliderPosition.x, y:sliderPosition.y + colorsStackView.bounds.height + 12)
        
        buttonsStackView.center = CGPoint(x: sliderPosition.x, y: buttonsStackView.bounds.height + 12)
        
        colorWheel.isHidden = true
        colorSwatch.clipsToBounds = true
        colorSwatch.layer.cornerRadius = colorSwatch.bounds.width/3.0
        
        exportButton.layer.cornerRadius = 12
    }
}

extension DrawViewController: SwiftyDrawViewDelegate {
    
    func swiftyDraw(shouldBeginDrawingIn drawingView: SwiftyDrawView, using touch: UITouch) -> Bool { return true }
    func swiftyDraw(didBeginDrawingIn drawingView: SwiftyDrawView, using touch: UITouch) {}
    func swiftyDraw(isDrawingIn drawingView: SwiftyDrawView, using touch: UITouch) {  }
    func swiftyDraw(didFinishDrawingIn drawingView: SwiftyDrawView, using touch: UITouch) {  }
    func swiftyDraw(didCancelDrawingIn drawingView: SwiftyDrawView, using touch: UITouch) {  }
}



extension DrawViewController {
    
    func addPinchGesture(view:UIView) {
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(DrawViewController.handlePinch(sender:)))
        drawView.addGestureRecognizer(pinch)
    }
    
    @objc func handlePinch(sender: UIPinchGestureRecognizer) {
        
        let zoomView = sender.view
        let scale = sender.scale
        
        
    }
}
