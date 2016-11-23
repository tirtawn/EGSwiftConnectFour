//
//  GameScene.swift
//  swiftConnectFour
//
//  Created by Eric Gu on 10/31/14.
//  Copyright (c) 2014 Eric Gu. All rights reserved.
//

import SpriteKit
import AVFoundation

var player: AVAudioPlayer?


class GameScene: SKScene {
    var game: Game!

    let TileWidth: CGFloat = 32.0
    let TileHeight: CGFloat = 36.0

    let boardLayer = SKNode()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }

    override init(size: CGSize) {
        super.init(size: size)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        let background = SKSpriteNode(imageNamed: "background")
        background.yScale = 2.0
        background.xScale = 2.0
        addChild(background)

        let layerPosition = CGPoint(
            x: -TileWidth * CGFloat(NumColumns) / 2,
            y: -TileHeight * CGFloat(NumRows) / 2)
       // let tilesLayer = SKNode()
        boardLayer.position = layerPosition
        //print ("Trying to redraw")
        boardLayer.zPosition=1
        addChild(boardLayer)
     //   print ("Trying to redraw 2")
        
       // boardLayer.setNeedsFocusUpdate()
    }

    func addTiles() {
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                let tileNode = SKSpriteNode(imageNamed: "Tile")
                tileNode.position = pointForColumn(column, row: row)
                tileNode.zPosition = 1
                boardLayer.addChild(tileNode)
            }
        }
    }

    func addSpriteForGamePiece(column: Int, _ row: Int, type: GamePieceType) {
        //let addedGamePiece = GamePiece(type: type)

        var pieceNode = SKSpriteNode(imageNamed: "Red")
        if (type == GamePieceType.black){
            pieceNode = SKSpriteNode(imageNamed: "Black")
        }

        pieceNode.position = pointForColumn(column, row:NumRows)
        pieceNode.zPosition=2 //Without this, it may go to the shade

        boardLayer.addChild(pieceNode)
        //animation
        let actualDuration = CGFloat(1.5)
        // Create the actions
        let actionMove = SKAction.move(to: pointForColumn(column, row: row), duration: TimeInterval(actualDuration))

        pieceNode.run(SKAction.sequence([actionMove]))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let location = touch?.location(in: boardLayer)
        let (success, column, _) = convertPoint(location!)
        if success {
            if isFinished {
                
                
                return
            }
            if let emptyRow = game.findEmptyPositionInColumn(column: column){

                game.addGamePieceToBoard(column, row: emptyRow)
                if(game.gamePieceOnBoard(column, emptyRow)!.type == GamePieceType.red) {
                    addSpriteForGamePiece(column: column, emptyRow, type: GamePieceType.red)
                } else {
                    addSpriteForGamePiece(column: column, emptyRow, type: GamePieceType.black)
                }

                game.checkWinCondition(column, row: emptyRow)
                
                if (isFinished)
                {
                    let alert = UIAlertController(title: "Four In a Row! Game Over", message:"Game Over", preferredStyle: .alert)
                    
                    playGameOverSound()
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
                     UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)             
                }
            }
        }
    }

    func pointForColumn(_ column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column)*TileWidth + TileWidth/2,
            y: CGFloat(row)*TileHeight + TileHeight/2)
    }

    func convertPoint(_ point: CGPoint) -> (success: Bool, column: Int, row: Int) {
        if point.x >= 0 && point.x < CGFloat(NumColumns)*TileWidth &&
            point.y >= 0 && point.y < CGFloat(NumRows)*TileHeight {
                return (true, Int(point.x / TileWidth), Int(point.y / TileHeight))
        } else {
            return (false, 0, 0)  // invalid location
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func playGameOverSound() {
        let url = Bundle.main.url(forResource: "gameover", withExtension: "m4a")!
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            
            player.prepareToPlay()
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
