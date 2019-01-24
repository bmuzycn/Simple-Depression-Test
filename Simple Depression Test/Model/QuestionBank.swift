//
//  QuestionBank.swift
//  Simple Depression Test
//
//  Created by Yu Zhang on 8/9/18.
//  Copyright © 2018 Yu Zhang. All rights reserved.
//

import UIKit
class QuestionBank {
    static let phq9 = ["Little interest or pleasure in doing things".localized, "Feeling down, depressed, or hopeless".localized, "Trouble falling or staying asleep, or sleeping too much".localized, "Feeling tired or having little energy".localized, "Poor appetite or overeating".localized, "Feeling bad about yourself or that you are a failure or have let yourself or your family down".localized, "Trouble concentrating on things, such as reading the newspaper or watching television".localized, "Moving or speaking so slowly that other people could have noticed. Or the opposite being so figety or restless that you have been moving around a lot more than usual".localized, "Thoughts that you would be better off dead, or of hurting yourself".localized, "If you checked off any problems, how difficult have these problems made it for you to do your work, take care of things at home, or get along with other people?".localized]
    static let gad7 = ["Feeling nervous, anxious or on edge".localized, "Not being able to stop or control worrying".localized, "Worrying too much about different things".localized, "Trouble relaxing".localized, "Being so restless that it is hard to sit still".localized, "Becoming easily annoyed or irritable".localized, "Feeling afraid as if something awful might happen".localized, "If you checked off any problems, how difficult have these problems made it for you to do your work, take care of things at home, or get along with other people?".localized]
    static let phqArray = ["Interest deficit (anhedonia)".localized,"Depressed mood".localized,"Sleep disorder (increased or decreased)".localized,"Energy deficit".localized,"Appetite disorder (increased or decreased)".localized,"Guilt (worthlessness, hopelessness, regret)".localized,"Concentration deficit".localized,"Psychomotor retardation or agitation".localized,"Suicidality".localized]
    
    static let gadArray = ["Feeling nervous or anxious".localized, "Difficult to control the worry".localized, "Worrying too much about different things".localized, "Trouble relaxing".localized, "Restlessness".localized, "Irritability".localized, "Feeling afraid".localized]
    
    static let phqArrayForRadar = ["Anhedonia".localized,"Low Mood".localized,"Sleep".localized,"Fatigue".localized,"Appetite".localized,"Worthlessness".localized,"Concentration".localized,"Movement".localized,"Suicide".localized,"Function impairment".localized]
    
    static let gadArrayForRadar = ["Feeling nervous".localized, "Difficult to ctrl...".localized, "Worry too much".localized, "Trouble relaxing".localized, "Restlessness".localized, "Irritability".localized, "Feeling afraid".localized, "Function impairment".localized]
    
    static let severityPHQ9 = ["None to minimal", "Mild", "Moderate", "Moderately severe", "Severe"]
    static let severityGAD7 = ["None to minimal", "Mild", "Moderate", "Severe"]
    static let severityColorForGAD7 = [UIColor.green, .yellow, .orange, .red]
    static let severityColorForPHQ9 = [UIColor.green, .yellow, .orange, .red, .purple]
    static var questions: [String] = QuestionBank.phq9
    static var questionArray: [String] = QuestionBank.phqArray
    static var radarArray: [String] = QuestionBank.phqArrayForRadar
    static var severityArray = severityPHQ9
    static var severityColors = severityColorForPHQ9
}
