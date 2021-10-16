//
//  GameScene.swift
//  Project17
//
//  Created by Keith Crooc on 2021-10-14.
//

// challenge!!
// 1. Stop the player from cheating by lifting their finger and tapping elsewhere – try implementing touchesEnded() to make it work. ✅
// 2. Make the timer start at one second, but then after 20 enemies have been made subtract 0.1 seconds from it so it’s triggered every 0.9 seconds. After making 20 more, subtract another 0.1, and so on. Note: you should call invalidate() on gameTimer before giving it a new value, otherwise you end up with multiple timers. ✅
// 3. Stop creating space debris after the player has died. ✅

import SpriteKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    
    var endScoreDisplay: SKLabelNode!
    
    var possibleEnemies = ["ball", "hammer", "tv"]
    var gameTimer: Timer?
    var isGameOver = false
    
    var enemyCountLabel: SKLabelNode!
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var enemyCount = 0 {
        didSet {
            enemyCountLabel.text = "Enemies: \(enemyCount)"
        }
    }
    
    var timeLevel = 1
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        starfield = SKEmitterNode(fileNamed: "starfield")!
        starfield.position = CGPoint(x: 1024, y: 384)
        starfield.advanceSimulationTime(10)
        addChild(starfield)
        starfield.zPosition = -1
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        enemyCountLabel = SKLabelNode(fontNamed: "Chalkduster")
        enemyCountLabel.position = CGPoint(x: 1000, y: 16)
        enemyCountLabel.horizontalAlignmentMode = .right
        addChild(enemyCountLabel)
        
        score = 0
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
            

    
    }
    
    @objc func createEnemy() {
        guard let enemy = possibleEnemies.randomElement() else { return }
        
        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        addChild(sprite)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularVelocity = 0
        
        enemyCount += 1
        
        if enemyCount > 5 && enemyCount < 10 {
            gameTimer?.invalidate()
            gameTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        } else if enemyCount > 10 && enemyCount < 20 {
            gameTimer?.invalidate()
            gameTimer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        
        if !isGameOver {
            score += 1
        }
    }
    
//    function that keeps player in bounds
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        var location = touch.location(in: self)
        
        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }
        
        player.position = location
    }
    
//    challenge #1: prevent player from cheating when they lift finger and place it elsewhere.
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        player.removeFromParent()
//        isGameOver = true
        endGame()
    }
    

    
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
//        why do we force unwrap it?
//        you could also guard let this as well. It's either there or not there in our main bundle.
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
//        isGameOver = true
        endGame()
    }
    
    
//    create a gameOver display
    func endGame() {
        isGameOver = true
        
        endScoreDisplay = SKLabelNode(fontNamed: "Chalkduster")
        endScoreDisplay.position = CGPoint(x: 512, y: 384)
        endScoreDisplay.text = "Score: \(score)"
        endScoreDisplay.fontSize = 120
        addChild(endScoreDisplay)
        
        scoreLabel.text = ""
        
// challenge #3 - stop producing debris when game is over.
        gameTimer?.invalidate()
        
    }
}
