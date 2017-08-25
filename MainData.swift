// messed up version
// Few things to remember
// blocks are made with a sub class of UILabel that holds their number
// there is definitely something going on with the randomize method


import UIKit

class GameViewController: UIViewController
{
    // MARK: - UI Outlets and variables for the game view
    var gameViewBg: UIView!
    var gameTimelabel: UILabel!
    var gameResetButton: UIButton!
    var gameViewWidth: Int = 0
    
    
    // MARK: - Game blocks, coordinates and mode
    var gameMode : Int!
    var blocksArr: NSMutableArray!
    var centersArr: NSMutableArray = []
    
    
    // MARK: - Game Timer
    var gameTimer: Timer = Timer()
    var curTime: Int = 0
    
    // MARK: - Game comparison stuff
    var compareState: Bool = false
    var firstLabel: MyLabel!
    var secondLabel: MyLabel!
    var tapIsAllowd: Bool = true
    var matchedSoFar: Int = 0
    
    
    // MARK: - Game initial settings
    override func viewDidAppear(_ animated: Bool)    {
        super.viewDidAppear(true);
        
        gameViewBg.layoutIfNeeded();
        gameViewWidth = Int(gameViewBg.bounds.size.width);
        
        self.resetAction((Any).self);
    }
    
    override func viewDidLoad()    {
        super.viewDidLoad()
        self.makeOutlets()
    }
    
    
    
    func makeOutlets ()    {
        let width = self.view.frame.size.width-40
        let y = 20 + (self.navigationController?.navigationBar.frame.size.height)! + 20
        
        gameViewBg.frame = CGRect(x: 20,
                                  y: y,
                                  width: width,
                                  height: width)
        gameViewBg.backgroundColor = UIColor.lightGray
        self.view.addSubview(gameViewBg)
        
        gameTimelabel.textAlignment = NSTextAlignment.center
        gameTimelabel = UILabel(frame: CGRect(x: 20,
                                              y: y + width + 20,
                                              width: width/2-10,
                                              height: 40))
        
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
                                  action: #selector(resetAction()),
                                  for: UIControlEvents.touchUpInside)
        
        self.view.addSubview(gameResetButton)
    }
    
    // MARK: - Making the blocks for the game based on the game mode
    func blockMakerAction()
    {
        var blockWidth: Int = gameViewWidth / gameMode;
        var xCen: Int = blockWidth / 2;
        var yCen: Int = blockWidth / 2;
        var counter: Int = 0;
        
        for v in 0..<gameMode
        {
            for h in 0..<gameMode
            {
                if counter == gameMode*gameMode/2
                {
                    counter = 0;
                }
                
                var block : MyLabel = MyLabel();
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
                
                block.numberTag = counter
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
    
    // MARK: Block Randomizer
    // this method ranomizes the location of different blocks
    func randomizeAction()
    {
        // We do this by first copying the centers for different blocks into a new array
        let temp: NSMutableArray = centersArr.mutableCopy() as! NSMutableArray;
        
        // we'd then iterate through the array of blocks and assign random centers to them
        
        for block in blocksArr
        {
            let randIndex: Int = Int( arc4random()) % temp.count;
            let randCen: CGPoint = temp[randIndex] as! CGPoint;
            (block as! MyLabel).center = randCen;
        }
    }
    
    // MARK: Game Reset method
    func resetAction()
    {
        // we begin by removing everything from the view
        for anyView in gameViewBg.subviews
        {
            anyView.removeFromSuperview();
        }
        
        // and empty the arrays
        blocksArr = [];
        centersArr = [];
        
        // then we remake the blocks and re-randomize them
        self.blockMakerAction();
        self.randomizeAction();
        
        
        for anyBlock in blocksArr
        {
            (anyBlock as! MyLabel).text = "?"
        }
        
        // we reset the timer values as well
        matchedSoFar = 0;
        curTime = 0;
        gameTimer.invalidate();
        gameTimer = Timer.scheduledTimer(timeInterval: 1,
                                         target: self,
                                         selector: "timerAction",
                                         userInfo: nil,
                                         repeats: true)
    }
    
    // MARK: - Timer Action
    @objc func timerAction()
    {
        // NEXT TWO LINES ARE FOR MEMORY / CPU TESTING
        // self.blockMakerAction()
        // self.randomizeAction()
        
        
        curTime += 1;
        let timeMins: Int = abs(curTime / 60);
        let timeSecs: Int = curTime % 60;
        
        let timeStr = NSString(format:"%02d\':%02d\"", timeMins, timeSecs);
        
        gameTimelabel.text = timeStr as String;
    }
    
    // MARK: - UI Responder Event
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        [super .touchesEnded(touches, with: event)]
        
        let myTouch = touches.first;
        
        if blocksArr.contains(myTouch?.view as Any) && tapIsAllowd
        {
            let thisLabel: MyLabel = myTouch!.view as! MyLabel;
            
            if compareState {
                firstLabel = thisLabel
            } else {
                secondLabel = thisLabel
            }
            
            UIView.transition(with: thisLabel,
                              duration: 0.75,
                              options:UIViewAnimationOptions.transitionFlipFromLeft,
                              animations: {
                                self.tapIsAllowd = false;
                                thisLabel.text =  thisLabel.numberTag as! String
                                
                                thisLabel.backgroundColor = UIColor.purple
            }, completion:
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
            })
        }
    }
    
    // MARK: Comparing two blocks happens in here
    func compareAction()
    {
        if firstLabel.numberTag == secondLabel.numberTag
        {
            self.hideThese(anyInp: [firstLabel, secondLabel])
            
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
                    self.firstLabel.backgroundColor = UIColor.darkGray
                    self.secondLabel.backgroundColor = UIColor.darkGray
                    firstLabel.text = "?"
                    secondLabel.text = "?"
            },
                              completion: nil);
        }
    }
    
    func hideThese(anyInp:Array<Any>) {
        
        for anyObj in anyInp
        {
            var thisBlock = anyObj as! MyLabel
            
            UIView.transition(with: self.view,
                              duration: 0.5,
                              options: UIViewAnimationOptions.transitionCrossDissolve,
                              animations:{
                                thisBlock.text = "😀"
                                thisBlock.backgroundColor = UIColor.green
            }, completion: nil);
        }
    }
}



class MyLabel : UILabel
{
    var numberTag: Int = 0
}






class TableViewCtrl: UIViewController {
    
    var objects :[Any] = [4,6,8,10,12]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = GameViewController
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playGameSegue" {
            
            let ctrl = segue.destination as! GameViewController
            let indexPath = tableView.indexPathForSelectedRow
            
            ctrl.gameMode = objects[(indexPath?.row)!] as! Int
            
            self.performSegue(withIdentifier: "playGameSegue", sender: sender)
        }
    }
    
    
    
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


