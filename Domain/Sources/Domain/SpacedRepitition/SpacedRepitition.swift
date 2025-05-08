//
//  SpacedRepitition.swift
//  Domain
//
//  Created by Kevin Kelly on 2/14/25.
//

import Foundation

/// https://github.com/open-spaced-repetition
/// https://expertium.github.io/
/// https://borretti.me/article/implementing-fsrs-in-100-lines
/// https://open-spaced-repetition.github.io/anki_fsrs_visualizer/
/// https://github.com/duolingo/halflife-regression
/// https://nothinghuman.substack.com/p/the-tyranny-of-the-marginal-user
/// https://www.youtube.com/watch?v=Anc2_mnb3V8 how neural networks learn
/// https://faqs.ankiweb.net/what-spaced-repetition-algorithm.html
/// https://www.supermemo.com/en/blog/application-of-a-computer-to-improve-the-results-obtained-in-working-with-the-supermemo-method
/// 


protocol SpacedRepititionAlgorithm {
    associatedtype StepContext
    
    func nextDate(base: Date, context: StepContext) -> Date
}
