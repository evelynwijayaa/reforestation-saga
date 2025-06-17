//
//  BarView.swift
//  ReforestationSaga
//
//  Created by Evelyn Wijaya on 16/06/25.
//

import SwiftUI

struct BarView: View {
    var treesRemaining: Int
    var totalPollution: Int
//    @State private var totalPollution: Int = 0
//    
//    init(treesRemaining: Int) {
//            self.treesRemaining = treesRemaining
//            self.totalPollution = treesRemaining // ambil nilai awal saat pertama dibuat
//        }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Pollution Indicator")
                .font(Font.custom("Gugi", size: 11))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.94, green: 0.84, blue: 0.65))
                .padding(.bottom, 8)
//                .background(.white)
           
            ZStack {
                Image("pollution")
                    .resizable(capInsets: EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8), resizingMode: .stretch)
                    .frame(width: CGFloat(16 * totalPollution), height: 31) // dinamis panjangnya
//                    .rotationEffect(Angle(degrees: 90))

                HStack(spacing: 2) {
                    ForEach((0..<totalPollution).reversed(), id: \.self) { index in
                        Rectangle()
                            .frame(width: 11.94, height: 19.52)
                            .foregroundColor(.clear)
                            .background(
                                index < (totalPollution - treesRemaining) ?
                                    Color(red: 0.99, green: 0.56, blue: 0.13).opacity(0.2) : // sudah bersih
                                    Color(red: 1, green: 0.18, blue: 0.18) // masih polusi
                            )
                            .cornerRadius(1.58)
                    }
                }
            }
            
            Text("Trees Remaining: \(treesRemaining)")
                .font(Font.custom("Gugi", size: 11))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.94, green: 0.84, blue: 0.65))
                .padding(.top, 12)
//            .background()
        }
//        .onChange(of: treesRemaining) { newValue in
//            // Kalau naik, berarti ganti level
//            if newValue > totalPollution {
//                totalPollution = newValue
//            }
//        }
//        .onAppear {
//            totalPollution = treesRemaining
//        }
    }
}


#Preview {
    BarView(treesRemaining: 2, totalPollution: 5)
        .padding()
        .background(.black)
}
