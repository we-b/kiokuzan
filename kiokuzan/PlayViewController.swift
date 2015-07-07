//
//  PlayViewController.swift
//  kiokuzan
//
//  Created by sdklt on 2015/07/04.
//  Copyright (c) 2015年 sdklt. All rights reserved.
//

import UIKit

class PlayViewController: UIViewController, NextButtonBoardDelegate, InputBoardDelegate {
  let screenWidth: Double = Double(UIScreen.mainScreen().bounds.size.width) // 画面の横幅
  let screenHeight: Double = Double(UIScreen.mainScreen().bounds.size.height) // 画面の縦
  let statusBarHeight: Double = Double(UIApplication.sharedApplication().statusBarFrame.height)
  let inputHeight: Double = 300.0 // どのデバイスでも入力フォームの高さは同じに
  
  var nextButtonBoard: NextButtonBoard!
  var inputBoard: InputBoard!
  var questionView: UIView!
  
  var questionArray: [Question] = []
  var totalQuestionNumber: Int = 20
  var backNumber: Int = 3
  var currentQuestionNumber: Int = 0
  var currentAnswerNumber: Int = 0
  var missCount: Int = 0
  
  var timerCountNum:Int = 0
  var timer = NSTimer()
  var missPenaltySecond = 5
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // 各ビューをセット
    self.nextButtonBoard = NextButtonBoard(screenWidth: self.screenWidth, screenHeight: self.screenHeight, viewHeight: self.inputHeight)
    self.nextButtonBoard.delegate = self
    self.inputBoard = InputBoard(screenWidth: self.screenWidth, screenHeight: self.screenHeight, viewHeight: self.inputHeight)
    self.inputBoard.delegate = self
    self.questionView = UINib(nibName: "QuestionView", bundle: nil).instantiateWithOwner(self, options: nil)[0] as! UIView

    // 問題作成
    questionArray = Question.generateQuestionArray(numberOfQuestions: self.totalQuestionNumber)

    // 問題表示
    self.questionView.frame = CGRect(x: 0, y: self.statusBarHeight, width: self.screenWidth, height: self.screenHeight - self.inputHeight - self.statusBarHeight)
    self.view.addSubview(questionView)
    updateQuestion()
    
    // 「次へ」ボタン
    self.view.addSubview(self.nextButtonBoard)
    
    // タイマー始動
    timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("updateTimer"), userInfo: nil, repeats: true)
  }

  func updateQuestion() {
    currentQuestionNumber++
    if (currentQuestionNumber > backNumber) {
      if (currentAnswerNumber + 1 > totalQuestionNumber) {
        timer.invalidate()
        performSegueWithIdentifier("fromPlayToResultSegue",sender: nil)
      } else {
        currentAnswerNumber++
      }
    }
    updateQuestionView()
  }
  
  func updateQuestionView() {
    if (self.currentQuestionNumber <= self.totalQuestionNumber) {
      var currentQuestion = self.questionArray[self.currentQuestionNumber - 1]
      (self.questionView.viewWithTag(2) as! UILabel).text = "Q\(self.currentQuestionNumber)"
      (self.questionView.viewWithTag(3) as! UILabel).text = "\(currentQuestion.firstItem) \(currentQuestion.operatorSymbol) \(currentQuestion.secondItem) = ?"
    } else {
      (self.questionView.viewWithTag(2) as! UILabel).text = ""
      (self.questionView.viewWithTag(3) as! UILabel).text = "Hang in there!"
    }
    if (self.currentAnswerNumber > 0) {
      (self.questionView.viewWithTag(4) as! UILabel).text = "Answer Q\(self.currentAnswerNumber)."
    } else {
      (self.questionView.viewWithTag(4) as! UILabel).text = ""
    }
  }
  
  func checkAnswer(numberText: String) {
    if (numberText == "Path") {
      self.missCount++
      self.timerCountNum += self.missPenaltySecond * 100
    } else {
      var inputNumber = numberText.toInt()
      if (self.questionArray[self.currentQuestionNumber - self.backNumber - 1].answer != inputNumber) {
        self.missCount++
        self.timerCountNum += self.missPenaltySecond * 100
      }
    }
  }
  
  func pushedNext() {
    updateQuestion()
    if (currentQuestionNumber > backNumber) {
      self.nextButtonBoard.removeFromSuperview()
      self.view.addSubview(self.inputBoard)
    }
  }

  func pushedNumber(numberText: String) {
    checkAnswer(numberText)
    updateQuestion()
  }
  
  func updateTimer() {
    timerCountNum++
    timeFormat(timerCountNum)
  }
  
  func timeFormat(countNum: Int) {
    let ms = countNum % 100
    let s = (countNum - ms) / 100 % 60
    let m = (countNum - s - ms) / 6000 % 3600
    (self.questionView.viewWithTag(1) as! UILabel).text = String(format: "%02d:%02d.%02d", m, s, ms)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    if (segue.identifier == "fromPlayToResultSegue") {
      // SecondViewControllerクラスをインスタンス化してsegue（画面遷移）で値を渡せるようにバンドルする
      var resultView :ResultViewController = segue.destinationViewController as! ResultViewController
      // secondView（バンドルされた変数）に受け取り用の変数を引数とし_paramを渡す（_paramには渡したい値）
      // この時SecondViewControllerにて受け取る同型の変数を用意しておかないとエラーになる
      resultView.timerCountNum = self.timerCountNum
      resultView.missCount = self.missCount
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
}
