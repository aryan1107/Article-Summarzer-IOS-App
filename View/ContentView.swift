//
//  ContentView.swift
//  Article Summarizer
//
//  Created by Aryan on 2022-02-20.
//

import SwiftUI
import Foundation
//import Purchases


struct Result2: Codable{
    var Summary: String
}
struct Result: Codable{
    var title: String
//    var authors: [String]
    var top_image: String
    var summary: String
}

class ViewModel: ObservableObject{
    func fetch (){
        
    }
}

struct ContentView: View {
    
    init() {
        
//            Purchases.configure(withAPIKey: "appl_wXqMYobEfXROvCXAyepjneZrFKO")
//            Purchases.debugLogsEnabled = true
            UITextView.appearance().backgroundColor = .clear
        }
    @State var summary: String = ""
    @State var title: String = ""
//    @State var authors: [String] = []
    @State var top_image: String = ""
    @State var Summary: String = ""
    
    @State private var url: String = ""
    @State private var text: String = ""
    @State private var usertext: String = "Enter Minimum 100 Words"
    @State private var showSummary = false
    @State private var sumy = false
    @State private var error:String = ""
    @State private var isLoading = false
    
    var body: some View {
        
        if showSummary{
            //Final Summary
            HStack {
//                Spacer()
                VStack{
//                    progressview
                    if isLoading{
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(3)
                    }
//                    top image
                    if (sumy == false) && (isLoading == false){
                        AsyncImage(url: URL(string: top_image)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .shadow(radius: 5)
                        } placeholder: {
                            Color.white
                        }
                    }
                    HStack {
                        VStack(alignment: .leading) {
                            if (sumy == false)&&(isLoading == false){
                                Text(title)
                                    .font(.title2)
                                    .fontWeight(.black)
                                    .foregroundColor(.primary)
                                    .lineLimit(3)
                                ScrollView{
                                    Text(summary)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                            }
                            else{
                                ScrollView{
                                    Text(Summary)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .shadow(radius: 5)
                                }
                            }
                            
                        }
                        .layoutPriority(100)
                        Spacer()
                    }
                    .padding()
                }
                Spacer()
            }
            .cornerRadius(8)
            .shadow(radius: 5)
//                back button
                Button(action: {
                    showSummary = false
                    url = ""
                    usertext = "Enter Minimum 100 Words"
                }, label: {
                    Text("Back")
                        .foregroundColor(Color.white)
                    
                })
                    .padding(8)
                    .background(Color(red: 0.067, green: 0.568, blue: 0.95))
                    .cornerRadius(3)
                    .shadow(radius: 3)
            }else{
            VStack{
                Spacer()
                    .frame(height: 100.0)
                //Title
                Text("📚 Article Summarizer")
                    .font(.title)
                //url input
                Spacer()
                    .frame(height: 50.0)
                HStack {
                    Spacer()
                        .frame(width: 15.0)
                    TextField("Enter Link", text: $url)
                        .padding(.all)
                        .disableAutocorrection(true)
                        .background(Color(red: 0.94902, green: 0.94902, blue: 0.94902))
                    Spacer()
                        .frame(width: 15.0)
                    }
//                or text option
                Text("OR")
                HStack {
                    Spacer()
                        .frame(width: 15.0)
                    TextEditor(text: $usertext)
                        .frame(height: 100.0)
                        .opacity(0.5)
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                        .background(Color(red: 0.94902, green: 0.94902, blue: 0.94902))
                    Spacer()
                        .frame(width: 15.0)
                    }
                //Button
                Spacer()
                    .frame(height: 20.0)
                Button(action: {
                    error = ""
//                    if usertext is unchanched do call urlAPi else call sumy
                    if ((usertext == "Enter Minimum 100 Words")||(usertext == "")) && (url != ""){
                        if validateUrl(urlString:url) == true{
                            Task {
                                    await urlApi(userUrl:url)
                                }
                            sumy = false
                            showSummary = true
                        }else{
                            error = "Enter Correct URL: It starts with http, check for spaces"
                            print("false")
                        }
                    }
                    else if ((usertext != "Enter Minimum 100 Words")&&(usertext != "")) && (url == ""){
//                        check if more than 100 words and call api
                        Task {
                                await textApi(string:usertext)
                            }
                        sumy = true
                        showSummary = true
                    }
                    else{
                        error = "Enter either URL or Words"
                    }
                    
                    
                }, label: {
                    Text("Submit")
                        .foregroundColor(Color.white)
                    
                })
                    .padding(5)
                    .frame(width: 150, height: 50)
                    .background(Color(red: 0.067, green: 0.568, blue: 0.95))
                    .cornerRadius(3)
                    .shadow(radius: 3)
                
                Spacer()

            }.ignoresSafeArea()
        }
        Text(error)
            .foregroundColor(Color.red)
        
        
    }
    
//   validate url
    func validateUrl (urlString: String?) -> Bool {
            let urlRegEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
            let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
            let result = urlTest.evaluate(with: urlString)
            return result
        }

    //    get data
    func urlApi(userUrl:String) async{
        isLoading = true
        guard let url = URL(string: "https://article-parser-and-summary-free-1000-requests.p.rapidapi.com/")else{
            return
        }
        print("Making api call")
        var request = URLRequest(url:url)
        //    method body and headers
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("article-parser-and-summary-free-1000-requests.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")
        request.setValue("yourkey", forHTTPHeaderField: "x-rapidapi-key")
        let body: [String: AnyHashable] = [
            "url":userUrl
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        //    make request
      
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else{
                return
            }
            do{
                let decodeResponse = try JSONDecoder().decode(Result.self, from: data)
//                print(decodeResponse)
                summary = decodeResponse.summary
                title = decodeResponse.title
//                authors = decodeResponse.authors
                top_image = decodeResponse.top_image
                isLoading = false
                
                
            }
            catch{
                print(error)
            }
        }
        task.resume()
    }
    
//    text api
    func textApi(string:String) async{
        guard let url = URL(string: "https://summarizer8.p.rapidapi.com/")else{
            return
        }
        print("Making api call")
        var request = URLRequest(url:url)
        //    method body and headers
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("summarizer8.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")
        request.setValue("yourkey", forHTTPHeaderField: "x-rapidapi-key")
        let body: [String: AnyHashable] = [
            "url":string,
            "sentenceCount": "6"
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        //    make request
      
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else{
                return
            }
            do{
                let decodeResponse = try JSONDecoder().decode(Result2.self, from: data)
//                print(decodeResponse)
                Summary = decodeResponse.Summary
                print(Summary)
                
            }
            catch{
                print(error)
            }
        }
        task.resume()
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
