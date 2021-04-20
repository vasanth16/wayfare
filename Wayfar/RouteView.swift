//
//  RouteView.swift
//  Wayfar
//
//  Created by Vasanth Rajasekaran on 4/8/21.
//  Copyright © 2021 Vasanth. All rights reserved.
//
import Liquid
import SwiftUI
import CDYelpFusionKit
import URLImage

var altRoute: [String:CDYelpBusiness] = [:]

struct RouteView: View {
    var route: [CDYelpBusiness] = []
    var body: some View {
        Text("From your current location, first head to...")
        List{
            ForEach(route, id: \.id){ r in
                RoutePlaceView(current: r)
                Text("Then head to...").bold().underline()
            }
            
        }.navigationBarTitle("Your Route")
        
}
}

struct RoutePlaceView: View{
    var current: CDYelpBusiness
    var body: some View{
        ZStack{
            Liquid()
                .frame(width: 340, height: 180, alignment: .center)
                .foregroundColor(.blue)
                .opacity(0.5)
            Liquid()
                .frame(width: 320, height: 140, alignment: .center)
                .foregroundColor(.blue)
                .opacity(0.3)
            Liquid(samples: 5)
                .frame(width: 300, height: 100, alignment: .center)
                .foregroundColor(.blue)
            Text(current.name ?? "Name").bold().frame(maxWidth: .infinity, alignment: .center).colorInvert()
            //Text(current.phone ?? "Phone")
            NavigationLink(destination: RouteDetailsView(current: current)){}
        }
    }
}

struct RouteDetailsView: View{
    var current: CDYelpBusiness
    var alts: [CDYelpBusiness] = []
    @State var next: Bool = false
    @State var yelp = yelpRequests()
    var body: some View{
        VStack{
            URLImage(url: current.imageUrl!) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            Text(current.name ?? "Name").bold().frame(maxWidth: .infinity, alignment: .center)
            Text(current.phone ?? "Phone")
            Text(String(current.rating!) + " Stars")
            //Text(String(format: "%f", current.location! as! CVarArg))
            
            if next{
                NavigationLink("Next", destination: AlternativesView(altOf: current, alternatives: yelp.busis)).foregroundColor(.white).padding().background(Color.accentColor) .cornerRadius(8)
            }else{
                Button(action:{
                    //self.alts = getAlts(business: current)
                    let newY = yelpRequests()
                    newY.getBusiness(interests: [current.categories![0].alias!], amount: 5, exception: current.name!, prices: ["$","$$","$$$"] )
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){
                        yelp = newY
                        print(yelp.busis)
                        next = true
                        print("bye")
                    }
                    
                }){
                    Text("Get Alternatives!")
                }.foregroundColor(.white).padding().background(Color.accentColor) .cornerRadius(8)
                
            }
        }
    }
}

struct AlternativesView: View{
    var altOf: CDYelpBusiness
    var alternatives: [CDYelpBusiness] = []
    var body: some View{
        List(alternatives, id: \.id){ alt in
            AlternativesPlaceView(current: alt, altOf: altOf)
        }.navigationBarTitle(Text("Alternatives"))
//        if next{
//
//        }else{
//        Button(action:{
//
//        })
//    }
    }
}

func removeCurrent(current: CDYelpBusiness){
    let currName = current.name!
    for i in 0...route.count-1{
        if currName == route[i].name!{
            continue
        }else{
            altRoute[route[i].name!] = route[i]
            
        }
    }
    
}
struct AlternativesPlaceView: View{
    var current: CDYelpBusiness
    var altOf: CDYelpBusiness
    var body: some View{
        Text(current.name ?? "Name").bold()
        Text(String(current.rating!) + " Stars")
        //Text(current.phone ?? "Phone")
        NavigationLink(destination: AlternativesDetailsView(current: current, altOf: altOf)){}
    }
}

struct AlternativesDetailsView: View{
    var current: CDYelpBusiness
    var altOf: CDYelpBusiness
    @State var next = false
    var body: some View{
        Text(current.name ?? "Name").bold().frame(maxWidth: .infinity, alignment: .center)
        Text(current.phone ?? "Phone")
        Text(String(current.rating!) + " Stars")
        Text(String(format: "%f", (current.distance!*0.000621371)))
        URLImage(url: current.imageUrl!) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        if next{
            NavigationLink("New Route", destination: RouteView(route: route)).foregroundColor(.white).padding().background(Color.accentColor) .cornerRadius(8)
        }else{
            Button("Select", action:{
                print("Hi")

                removeCurrent(current: altOf)
                altRoute[current.name!] = current
                print(altRoute)
                let altCalc = TravelCalc()
                print(altRoute)
                altCalc.main(places: altRoute)
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0){
                    route = altCalc.optimalList
                    next = true
                }
            }).foregroundColor(.white).padding().background(Color.accentColor) .cornerRadius(8)
        }
    }
}


struct RouteView_Previews: PreviewProvider {
    static var previews: some View {
        RouteView()
    }
}
