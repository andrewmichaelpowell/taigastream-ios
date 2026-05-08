//  Taiga Stream
//  github.com/andrewmichaelpowell

import SwiftUI
import WidgetKit

@main
struct TaigaStreamWidgetBundle: WidgetBundle
{
    @WidgetBundleBuilder
    var body: some Widget
    {
        TaigaStreamWidgetControl1()
        TaigaStreamWidgetControl2()
        TaigaStreamWidgetControl3()
        TaigaStreamWidgetControl4()
    }
}
