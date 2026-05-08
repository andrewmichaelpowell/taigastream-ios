//
//  TaigaStreamControlBundle.swift
//  TaigaStreamControl
//
//  Created by Andrew Powell on 08.05.26.
//

import WidgetKit
import SwiftUI

@main
struct TaigaStreamControlBundle: WidgetBundle {
    var body: some Widget {
        TaigaStreamControl()
        TaigaStreamControlControl()
        TaigaStreamControlLiveActivity()
    }
}
