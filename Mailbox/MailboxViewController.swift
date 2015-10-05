//
//  MailboxViewController.swift
//  Mailbox
//
//  Created by Cameron Wu on 9/29/15.
//  Copyright © 2015 Cameron Wu. All rights reserved.
//

import UIKit

class MailboxViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    // Outlets & Vars ----------------------------------
    
    @IBOutlet weak var mailboxMasterView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var mailboxSegmentedControl: UISegmentedControl!
    @IBOutlet weak var navLayerTop: UIImageView!
    @IBOutlet weak var navLayerBottom: UIImageView!
    @IBOutlet weak var feedScrollView: UIScrollView!
    @IBOutlet weak var feedImageView: UIImageView!
    @IBOutlet weak var archiveScrollView: UIScrollView!
    @IBOutlet weak var messageContainerView: UIView!
    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet var messagePanGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet weak var leftIconImageView: UIImageView!
    @IBOutlet weak var rightIconImageView: UIImageView!
    @IBOutlet weak var composeMasterView: UIView!
    @IBOutlet weak var composeContentView: UIView!
    @IBOutlet weak var composeImageView: UIImageView!
    @IBOutlet weak var composeToTextField: UITextField!
    
    var overlayView: UIImageView!
    var closeOverlayGesture: UITapGestureRecognizer!
    
    var edgeGesture: UIScreenEdgePanGestureRecognizer!
    var menuClosePanGesture: UIPanGestureRecognizer!
    var menuCloseTapGesture: UITapGestureRecognizer!
    let openPosition: CGFloat = 285
    var masterCurrentXPosition: CGFloat!
    
    var feedScrollCurrentYPosition: CGFloat!
    
    let initialFeedPosition: CGFloat = 165
    let initialFeedImageHeight: CGFloat = 86
    let initialContentSize: CGSize = CGSizeMake(320, 1367.5)
    
    let defaultTransitionTime: NSTimeInterval = 0.3
    var previousTab = 1
    
    enum messageState {
        case reschedule
        case list
        case archive
        case delete
        case normal
    }
    

    // Alerts ------------------------------------------
    
    let undoController = UIAlertController(title: "Undo last action?", message: "Are you sure you want to undo and move 1 item from Archive back to Inbox?", preferredStyle: .Alert)
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
    let undoAction = UIAlertAction(title: "Undo", style: .Default, handler: nil)
    
    let closeComposeController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
    
    
    // Default Functions -------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initial setup
        feedScrollView.delegate = self
        feedScrollView.contentSize = initialContentSize
        feedScrollView.contentOffset = CGPointMake(0, 79.5)
        
        archiveScrollView.delegate = self
        archiveScrollView.frame.origin.x = 320
        archiveScrollView.contentSize = CGSizeMake(320, 1244)
        archiveScrollView.contentOffset = CGPointMake(0, 42.5)
        
        contentView.clipsToBounds = true
            
        leftIconImageView.center = CGPointMake(30, messageImageView.center.y)
        rightIconImageView.center = CGPointMake(290, messageImageView.center.y)
        
        edgeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: "menuPan:")
        edgeGesture.edges = UIRectEdge.Left
        edgeGesture.delegate = self
        mailboxMasterView.addGestureRecognizer(edgeGesture)
        
        undoController.addAction(cancelAction)
        undoController.addAction(undoAction)
        
        let deleteDraft = UIAlertAction(title: "Delete Draft", style: .Destructive) { (action) in
            self.closeCompose()
        }
        
        let keepDraft = UIAlertAction(title: "Keep Draft", style: .Default) { (action) in
            self.closeCompose()
        }
        
        closeComposeController.view.tintColor = UIColorFromRGB("51B9DB")
        closeComposeController.addAction(deleteDraft)
        closeComposeController.addAction(keepDraft)
        closeComposeController.addAction(cancelAction)
        
        composeContentView.frame.origin.y = view.frame.height
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            print("Whoa, I'm shaking!")
            presentViewController(undoController, animated: true, completion: nil)
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIScreenEdgePanGestureRecognizer {
            return true
        } else {
            return false
        }
    }
    
    
    // Menu Open and Close Functions -------------------
    
    func menuPan(sender: UIPanGestureRecognizer) {
        let point = sender.locationInView(view)
        let velocity = sender.velocityInView(view)
        let translation = sender.translationInView(view)
        
        if sender.state == .Began {
            print("Menu pan began.")
            masterCurrentXPosition = mailboxMasterView.frame.origin.x
            contentView.userInteractionEnabled = false
        } else if sender.state == .Changed {
            print("Menu is panning.")
            if mailboxMasterView.frame.origin.x >= 0 && mailboxMasterView.frame.origin.x <= 320 {
                mailboxMasterView.frame.origin.x = masterCurrentXPosition + translation.x
            }
        } else if sender.state == .Ended {
            print("Menu pan ended.")
            releaseLeftOrRight(velocity)
        }
    }
    
    func releaseLeftOrRight(velocity: CGPoint) {
        if velocity.x > 0 {
            print("Release right.")
            openMenu()
        } else {
            print("Release left.")
            closeMenu()
        }
    }
    
    func openMenu() {
        UIView.animateWithDuration(defaultTransitionTime, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
            self.mailboxMasterView.frame.origin.x = self.openPosition
            }, completion: {
                finished in
                self.contentView.userInteractionEnabled = false
                self.menuClosePanGesture = UIPanGestureRecognizer(target: self, action: "menuPan:")
                self.mailboxMasterView.addGestureRecognizer(self.menuClosePanGesture)
                self.menuCloseTapGesture = UITapGestureRecognizer(target: self, action: "closeMenu")
                self.mailboxMasterView.addGestureRecognizer(self.menuCloseTapGesture)
                
        })
    }
    
    func closeMenu() {
        UIView.animateWithDuration(defaultTransitionTime, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
            self.mailboxMasterView.frame.origin.x = 0
            }, completion: {
                finished in
                if self.menuClosePanGesture != nil && self.menuCloseTapGesture != nil {
                    self.mailboxMasterView.removeGestureRecognizer(self.menuClosePanGesture)
                    self.mailboxMasterView.removeGestureRecognizer(self.menuCloseTapGesture)
                }
                self.contentView.userInteractionEnabled = true
        })
    }
    
    @IBAction func pressOpenMenuButton(sender: UIButton) {
        openMenu()
    }
    
    
    // Message Pan, Position, and Reset Functions ------

    @IBAction func messagePan(sender: UIPanGestureRecognizer) {
        if sender.state == .Began {
            print("Dragging began.")
        } else if sender.state == .Changed {
            let translation = sender.translationInView(self.view)
            if let view = sender.view {
                view.center = CGPoint(x:view.center.x + translation.x,
                    y:view.center.y)
            }
            sender.setTranslation(CGPointZero, inView: self.view)
            updateMessageState(checkPosition(self.messageImageView))
            //feedScrollView.contentOffset.y = feedScrollView.contentOffset.y - translation.y
        } else if sender.state == .Ended {
            print("Dragging ended.")
            switch checkPosition(self.messageImageView) {
            case .normal:
                UIView.animateWithDuration(defaultTransitionTime, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: { () -> Void in
                    self.messageImageView.frame.origin.x = 0
                    self.leftIconImageView.center.x = 30
                    self.rightIconImageView.center.x = 290
                    }, completion: nil)
            case .reschedule:
                UIView.animateWithDuration(defaultTransitionTime, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: { () -> Void in
                    self.messageImageView.frame.origin.x = -380
                    self.rightIconImageView.center.x = -350
                    }, completion: nil)
                revealOverlayMenu(.reschedule)
            case .list:
                UIView.animateWithDuration(defaultTransitionTime, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: { () -> Void in
                    self.messageImageView.frame.origin.x = -380
                    self.rightIconImageView.center.x = -30
                    }, completion: nil)
                revealOverlayMenu(.list)
            case .archive, .delete:
                UIView.animateWithDuration(defaultTransitionTime, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: { () -> Void in
                    self.messageImageView.frame.origin.x = 380
                    self.leftIconImageView.center.x = 350
                    }, completion: {
                        finished in
                        self.closeAndResetMessage()
                })
            }
        }
    }
    
    func checkPosition(view: UIImageView!) -> messageState {
        //print("\(view).frame.origin.x is: \(view.frame.origin.x)")
        if view.frame.origin.x < -60 && view.frame.origin.x >= -260 {
            return .reschedule
        } else if view.frame.origin.x < -260 {
            return .list
        } else if view.frame.origin.x > 60 && view.frame.origin.x <= 260 {
            return .archive
        } else if view.frame.origin.x > 260 {
            return .delete
        } else {
            return .normal
        }
    }
    
    func updateMessageState(state: messageState) {
        switch state {
        case .reschedule:
            print("Reschedule")
            messageContainerView.backgroundColor = UIColorFromRGB("FFDE47")
            rightIconImageView.image = UIImage(named: "later_icon")
            rightIconImageView.alpha = 1
            rightIconImageView.center.x = messageImageView.frame.origin.x + messageImageView.frame.width + 30
            leftIconImageView.alpha = 0
        case .list:
            print("List")
            messageContainerView.backgroundColor = UIColorFromRGB("D8A675")
            rightIconImageView.image = UIImage(named: "list_icon")
            rightIconImageView.alpha = 1
            rightIconImageView.center.x = messageImageView.frame.origin.x + messageImageView.frame.width + 30
            leftIconImageView.alpha = 0
        case .archive:
            print("Archive")
            messageContainerView.backgroundColor = UIColorFromRGB("62D962")
            leftIconImageView.image = UIImage(named: "archive_icon")
            leftIconImageView.alpha = 1
            leftIconImageView.center.x = messageImageView.frame.origin.x - 30
            rightIconImageView.alpha = 0
        case .delete:
            print("Delete")
            messageContainerView.backgroundColor = UIColorFromRGB("EF540C")
            leftIconImageView.image = UIImage(named: "delete_icon")
            leftIconImageView.alpha = 1
            leftIconImageView.center.x = messageImageView.frame.origin.x - 30
            rightIconImageView.alpha = 0
        case .normal:
            print("Normal")
            messageContainerView.backgroundColor = UIColorFromRGB("E3E3E3")
            if messageImageView.frame.origin.x >= -60 && messageImageView.frame.origin.x <= -20 {
                var percentage = abs((messageImageView.frame.origin.x + 20) / 40)
                print("Percentage is \(percentage)")
                rightIconImageView.alpha = percentage
            } else if messageImageView.frame.origin.x <= 60 && messageImageView.frame.origin.x >= 20 {
                var percentage = abs((messageImageView.frame.origin.x - 20) / 40)
                print("Percentage is \(percentage)")
                leftIconImageView.alpha = percentage
            }
        }
    }
    
    func closeAndResetMessage() {
        UIView.animateWithDuration(defaultTransitionTime, animations: { () -> Void in
            self.feedImageView.frame.origin.y = self.initialFeedPosition - self.initialFeedImageHeight
            self.feedScrollView.contentSize = CGSizeMake(320, self.initialContentSize.height - self.initialFeedImageHeight)
            }, completion: {
                finished in
                self.messageImageView.frame.origin.x = 0
                self.leftIconImageView.center.x = 30
                self.rightIconImageView.center.x = 290
                UIView.animateWithDuration(0.5, delay: 1, options: .CurveEaseOut, animations: { () -> Void in
                    self.feedImageView.frame.origin.y = self.initialFeedPosition
                    self.feedScrollView.contentSize = CGSizeMake(320, self.initialContentSize.height)
                    }, completion: nil)
        })
    }
    
    
    // Reveal Overlays ---------------------------------
    
    func revealOverlayMenu(state: messageState) {
        switch state {
        case .reschedule:
            print("Creating Reschedule")
            overlayView = UIImageView(image: UIImage(named: "reschedule"))
        case .list:
            print("Creating List")
            overlayView = UIImageView(image: UIImage(named: "list"))
        default:
            break
        }
        
        overlayView.frame = CGRect(x: 0, y: 0, width: 320, height: 568)
        view.addSubview(overlayView)

        closeOverlayGesture = UITapGestureRecognizer(target: self, action: "closeOverlay")
        overlayView.addGestureRecognizer(closeOverlayGesture)
        overlayView.userInteractionEnabled = true
        
        overlayView.center = view.center
        overlayView.alpha = 0
        
        UIImageView.animateWithDuration(defaultTransitionTime, animations: { () -> Void in
            self.overlayView.alpha = 1
            }, completion: nil)
    }
    
    func closeOverlay() {
        print("Closing overlay!")
        UIImageView.animateWithDuration(defaultTransitionTime, animations: { () -> Void in
            self.overlayView.alpha = 0
            }, completion: {
                finished in
                self.overlayView.removeFromSuperview()
                self.closeAndResetMessage()
        })
    }
    
    
    // Compose UI --------------------------------------
    
    @IBAction func pressComposeButton(sender: UIButton) {
        print("Composed button pressed.")
        openCompose()
    }
    
    @IBAction func pressComposeCancelButton(sender: UIButton) {
        presentViewController(closeComposeController, animated: true) {}
    }
    
    func openCompose() {
        print("Composing began.")
        self.composeMasterView.alpha = 1
        self.composeContentView.frame.origin.y = view.frame.height
        UIView.animateWithDuration(defaultTransitionTime, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
            self.composeContentView.frame.origin.y = 20
            self.composeMasterView.backgroundColor = UIColorFromRGB("000000", alpha: 0.33)
            }, completion: nil)
        self.composeToTextField.becomeFirstResponder()
    }
    
    func closeCompose() {
        print("Composing ended.")
        UIView.animateWithDuration(defaultTransitionTime, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
            self.composeContentView.frame.origin.y = self.view.frame.height
            self.composeMasterView.backgroundColor = UIColorFromRGB("000000", alpha: 0.0)
            }, completion: {
                finished in
                self.composeMasterView.alpha = 0
        })
        self.composeContentView.endEditing(true)
    }
    
    
    // Scroll Snapping ---------------------------------
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("Scroll drag stopped for \(scrollView)")
        if scrollView == self.feedScrollView {
            if feedScrollView.contentOffset.y >= 0 && feedScrollView.contentOffset.y <= 18.5 {
                UIView.animateWithDuration(defaultTransitionTime, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
                    self.feedScrollView.contentOffset.y = 0
                    }, completion: nil)
            } else if feedScrollView.contentOffset.y > 18.5 && feedScrollView.contentOffset.y <= 37 {
                UIView.animateWithDuration(defaultTransitionTime, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
                    self.feedScrollView.contentOffset.y = 37
                    }, completion: nil)
            } else if feedScrollView.contentOffset.y > 37 && feedScrollView.contentOffset.y <= 58 {
                UIView.animateWithDuration(defaultTransitionTime, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
                    self.feedScrollView.contentOffset.y = 37
                    }, completion: nil)
            } else if feedScrollView.contentOffset.y > 58 && feedScrollView.contentOffset.y <= 79.5 {
                UIView.animateWithDuration(defaultTransitionTime, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
                    self.feedScrollView.contentOffset.y = 79.5
                    }, completion: nil)
            }
        } else if scrollView == self.archiveScrollView {
            if archiveScrollView.contentOffset.y >= 0 && archiveScrollView.contentOffset.y <= 21 {
                UIView.animateWithDuration(defaultTransitionTime, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
                    self.archiveScrollView.contentOffset.y = 0
                    }, completion: nil)
            } else if archiveScrollView.contentOffset.y > 21 && archiveScrollView.contentOffset.y <= 42.5 {
                UIView.animateWithDuration(defaultTransitionTime, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
                    self.archiveScrollView.contentOffset.y = 42.5
                    }, completion: nil)
            }
        }
    }
    
    // Switch Tabs -------------------------------------
    
    @IBAction func switchTabs(sender: AnyObject) {
        switch mailboxSegmentedControl.selectedSegmentIndex {
        case 0:
            print("Later selected.")
            updateNavBar(0)
        case 1:
            print("Mailbox selected.")
            updateNavBar(1)
        case 2:
            print("Archived selected.")
            updateNavBar(2)
        default:
            break
        }
    }
    
    func updateNavBar(tab: Int) {
        var color: String!
        var tabName: String!
        
        switch tab {
        case 0:
            color = "FFD320"
            tabName = "nav_later"
            slideFeedsRight(0)
        case 1:
            color = "51B9DB"
            tabName = "nav_mailbox"
            if previousTab < 1 {
                print("Sliding feeds right...!")
                slideFeedsLeft(1)
            } else if previousTab > 1 {
                print("Sliding feeds left...!")
                slideFeedsRight(1)
            }
        case 2:
            color = "62D962"
            tabName = "nav_archived"
            slideFeedsLeft(2)
        default:
            break
        }
        
        self.navLayerBottom.image = UIImage(named: tabName)
        UIView.animateWithDuration(defaultTransitionTime, animations: { () -> Void in
            self.mailboxSegmentedControl.tintColor = UIColorFromRGB(color)
            self.navLayerTop.alpha = 0
            }, completion: {
                finished in
                self.navLayerTop.image = self.navLayerBottom.image
                self.navLayerTop.alpha = 1
        })
    }
    
    func slideFeedsRight(nextTab: Int) {
        print("slideFeedsRight: previousTab is: \(previousTab), nextTab is: \(nextTab)")
        var nextView: UIView!
        var previousView: UIView!
        
        if previousTab == 1 {
            previousView = self.feedScrollView
        } else if previousTab == 2 {
            previousView = self.archiveScrollView
        }
        
        if nextTab == 0 {
            nextView == nil
        } else if nextTab == 1 {
            nextView = self.feedScrollView
            feedScrollView.contentOffset = CGPointMake(0, 79.5)
        }
        
        if nextView != nil {
            nextView.frame.origin.x = -320
        }
        UIView.animateWithDuration(defaultTransitionTime, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
            previousView.frame.origin.x = 320
            if nextView != nil {
                nextView.frame.origin.x = 0
            }
            }, completion: {
                finished in
                self.previousTab = nextTab
                print("previousTab is now: \(nextTab)")
        })
    }
    
    func slideFeedsLeft(nextTab: Int) {
        print("slideFeedsLeft: previousTab is: \(previousTab), nextTab is: \(nextTab)")
        var nextView: UIView!
        var previousView: UIView!
        
        if previousTab == 0 {
            previousView = nil
        } else if previousTab == 1 {
            previousView = self.feedScrollView
        }
        
        if nextTab == 1 {
            nextView = self.feedScrollView
            feedScrollView.contentOffset = CGPointMake(0, 79.5)
        } else if nextTab == 2 {
            nextView = self.archiveScrollView
            archiveScrollView.contentOffset = CGPointMake(0, 42.5)
        }
        
        nextView.frame.origin.x = 320
        UIView.animateWithDuration(defaultTransitionTime, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
            if previousView != nil {
                previousView.frame.origin.x = -320
            }
            nextView.frame.origin.x = 0
            }, completion: {
                finished in
                self.previousTab = nextTab
                print("previousTab is now: \(nextTab)")
        })
    }
}
