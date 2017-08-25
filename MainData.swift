import UIKit

class GameViewController: UIViewController
{

    // MARK: - Vars
    var gameViewBg: UIView!
    var gameTimelabel: UILabel!
    var gameResetButton: UIButton!
       var gameMode : Int = 4;

    var gameViewWidth: Int = 0;
    var blocksArr: NSMutableArray = [];
    var centersArr: NSMutableArray = [];

    var gameTimer: Timer = Timer();
    var curTime: Int = 0;
    
    var compareState: Bool = false;
    var indOfFirstButton: Int = 0;
    var indOfSecondButton: Int = 0;
    var tapIsAllowd: Bool = true;
    
    var matchedSoFar: Int = 0;
    
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(true);
        
        gameViewBg.layoutIfNeeded();
        gameViewWidth = Int(gameViewBg.bounds.size.width);

        self.resetAction((Any).self);
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        let width = self.view.frame.size.width-40
        let y = 20 + (self.navigationController?.navigationBar.frame.size.height)! + 20
        
        gameViewBg = UIView()
        gameViewBg.frame = CGRect(x: 20,
                                  y: y,
                                  width: width,
                                  height: width)
        gameViewBg.backgroundColor = UIColor.lightGray
        self.view.addSubview(gameViewBg)

        
        
//        gameTimelabel.textAlignment = NSTextAlignment.center
        gameTimelabel = UILabel(frame: CGRect(x: 20,
                                              y: y + width + 20,
                                              width: width/2-10,
                                              height: 40))
        
        gameTimelabel.textAlignment = NSTextAlignment.center

        gameTimelabel.backgroundColor = UIColor.darkGray
        self.view.addSubview(gameTimelabel)
        
        
        
        gameResetButton = UIButton()
        gameResetButton.frame = CGRect(x: 20+10+width/2,
                                       y: y + width + 20,
                                       width: width/2-10,
                                       height: 40)
        gameResetButton.backgroundColor = UIColor.darkGray
        gameResetButton.setTitle("Reset", for: UIControlState.normal)
        gameResetButton.addTarget(self,
                                  action: #selector(resetAction(_:)),
                                  for: UIControlEvents.touchUpInside)
        
        self.view.addSubview(gameResetButton)
        
        
    }
    

    func blockMakerAction()
    {
        let blockWidth: Int = gameViewWidth / gameMode;
        var xCen: Int = blockWidth / 2;
        var yCen: Int = blockWidth / 2;
        var counter: Int = 0;
        
        for _ in 0..<gameMode
        {
            for _ in 0..<gameMode
            {
                if counter == 8
                {
                    counter = 0;
                }
                
                let block : UILabel = UILabel();
                let blockFrame : CGRect = CGRect (x: 0,
                                                  y: 0,
                                                  width: blockWidth-(40/gameMode),
                                                  height: blockWidth-(40/gameMode));
                block.frame = blockFrame;
                block.text = String(counter)
                block.font = UIFont.boldSystemFont(ofSize: CGFloat(120 / gameMode))
                block.textAlignment = NSTextAlignment.center
                block.backgroundColor = UIColor.darkGray
                
                let newCenter: CGPoint = CGPoint(x: xCen, y: yCen);
                block.center = newCenter;
                
                block.isUserInteractionEnabled = true;
                
                blocksArr.add(block);
                
                centersArr.add( newCenter);
                
                gameViewBg.addSubview(block);
                
                counter = counter + 1;
                
                xCen = xCen + blockWidth;
                
            }
            
            yCen = yCen + blockWidth;
            xCen = blockWidth / 2;
        }
    }
    
    func randomizeAction()
    {
        let temp: NSMutableArray = centersArr.mutableCopy() as! NSMutableArray;
        
        for block in blocksArr
        {
            let randIndex: Int = Int( arc4random()) % temp.count;
            let randCen: CGPoint = temp[randIndex] as! CGPoint;
            (block as! UILabel).center = randCen;
            temp.removeObject(at: randIndex);
        }
    }
    
    @IBAction func resetAction(_ sender: Any)
    {
        for anyView in gameViewBg.subviews
        {
            anyView.removeFromSuperview();
        }
        
        blocksArr = [];
        centersArr = [];
        
        self.blockMakerAction();
        self.randomizeAction();
        
        for anyBlock in blocksArr
        {
            (anyBlock as! UILabel).text = "?"
        }
        
        matchedSoFar = 0;
        curTime = 0;
        gameTimer.invalidate();
        gameTimer = Timer.scheduledTimer(timeInterval: 1,
                                         target: self,
                                         selector: "timerAction",
                                         userInfo: nil,
                                         repeats: true)
    }
    
    @objc func timerAction()
    {
        curTime += 1;
        let timeMins: Int = abs(curTime / 60);
        let timeSecs: Int = curTime % 60;
        
        let timeStr = NSString(format:"%02d\':%02d\"", timeMins, timeSecs);
        
        gameTimelabel.text = timeStr as String;
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let myTouch = touches.first;
        
        if blocksArr.contains(myTouch?.view as Any) && tapIsAllowd
        {
            let thisButton: UILabel = myTouch!.view as! UILabel;
            
            var indOfButton : Int =  blocksArr.index(of: thisButton);
            
            if compareState
            {
                indOfSecondButton = indOfButton;
            }
            else
            {
                indOfFirstButton = indOfButton;
            }
            
            if indOfButton >= gameMode*gameMode/2
            {
                indOfButton = indOfButton - gameMode*gameMode/2;
            }
            
            UIView.transition(with: thisButton,
                              duration: 0.75,
                              options:UIViewAnimationOptions.transitionFlipFromLeft,
                              animations:
                {
                    self.tapIsAllowd = false;
                    thisButton.text = String( indOfButton)
            },
                              completion:
                { (true) in
                    
                    self.tapIsAllowd = true;
                    if self.compareState
                    {
                        self.compareAction();
                        self.compareState = false;
                    }
                    else
                    {
                        self.compareState = true;
                    }
            }
            );
        }
    }
    
    
    
    func compareAction()
    {
        let firstButton:UILabel = blocksArr[indOfFirstButton] as! UILabel;
        let secondButton:UILabel = blocksArr[indOfSecondButton] as! UILabel;
        
        
        let dist: Int = abs(indOfFirstButton-indOfSecondButton);
        
        if dist == gameMode*gameMode/2
        {
            UIView.beginAnimations(nil, context: nil);
            UIView.setAnimationDuration(0.5);
            firstButton.alpha = 0.0;
            secondButton.alpha = 0.0;
            UIView.commitAnimations();
            
            
            matchedSoFar = matchedSoFar + 1;
            
            if  matchedSoFar == gameMode*gameMode/2
            {
                self.resetAction(gameMode);
            }
        }
        else
        {
            UIView.transition(with: self.view,
                              duration: 0.5,
                              options: UIViewAnimationOptions.transitionCrossDissolve,
                              animations:
                {
                    firstButton.text = "?"
                    secondButton.text = "?"
            },
                              completion: nil);
        }
    }
}


class TableViewCtrl: UITableViewController {
    
    var objects = [Any]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        objects.append(4)
        objects.append(6)
        objects.append(8)
        objects.append(10)
        objects.append(12)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playGameSegue" {
            
            let ctrl = segue.destination as! GameViewController
            let indexPath = tableView.indexPathForSelectedRow

                
            ctrl.gameMode = objects[(indexPath?.row)!] as! Int
            }
        }
    
    
    // MARK: - Table View

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let object = "Play " + String(describing: objects[indexPath.row])
        
        cell.textLabel!.text = object.description
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.performSegue(withIdentifier: "playGameSegue", sender: indexPath)
    }
    
    
}
