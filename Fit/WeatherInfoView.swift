//
//  WeatherInfoView.swift
//  Fit
//
//  Created by Taiwu Chen on 2025-02-09.
//
import SwiftUI

struct WeatherInfoView: View {
    @State private var weather: String = "Sunny, 75°F"  // Placeholder weather info

    var body: some View {
        HStack {
            Image(systemName: "sun.max.fill")
                .foregroundColor(.yellow)
            Text(weather)
                .font(.body)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
        .padding([.horizontal, .bottom])
    }
}

struct WeatherInfoView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherInfoView()
    }
}
