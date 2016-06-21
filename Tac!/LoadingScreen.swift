//
//  LoadingScreen.swift
//  
//
//  Created by Dylan Reich on 9/14/15.
//
//


class LoadingScreen: UIView {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var topText: UILabel!
    @IBOutlet weak var subTitleText: UILabel!
    @IBOutlet var backToMenuButton : UIButton!
    @IBOutlet weak var spinnerView: LoaderView!
    var loadingSpinnerTimer : NSTimer!
    
    override func awakeFromNib() {
        self.loadingSpinnerTimer = NSTimer.scheduledTimerWithTimeInterval(2.75, target: self, selector: Selector("spinSpinner"), userInfo: nil, repeats: true)
        self.loadingSpinnerTimer.fire()
    }
    
    func spinSpinner() {
        self.spinnerView.addStartLoaderAnimation()
    }
}
