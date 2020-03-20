//
//  ContentView.swift
//  Google Book
//
//  Created by Himash Nadeeshan on 3/20/20.
//  Copyright © 2020 Himash Nadeeshan. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI
import SwiftyJSON
import WebKit

struct ContentView: View {
    var body: some View {
        
        NavigationView{
            Home()
            .navigationBarTitle(Text("Books"))
        }
        
    }
}

struct Home : View {
    
    @ObservedObject var books = GetData()
    @State var show = false
    @State var url = ""
    @State var txt = ""
    
    var body : some View{
        
        VStack{
            
            HStack{
                
                TextField("Search", text: self.$txt)
                
                Button(action: {
            
                    
                }, label: {
                    Image(systemName: "magnifyingglass")
                    .foregroundColor(Color.black)
                })
                
            }.padding()
            
            List(books.data){i in

                HStack{
                                
                    if i.imgurl != ""{
                        
                      WebImage(url: URL(string: i.imgurl)!)
                        .resizable()
                        .frame(width: 120, height: 170)
                        .cornerRadius(10)
                        
                    }else{
                        Image("books").resizable().frame(width: 120, height: 170).cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        
                        Text(i.title).fontWeight(.bold)
                        
                        Text(i.authors)
                        
                        Text(i.desc).font(.caption)
                            .lineLimit(4)
                            .multilineTextAlignment(.leading)
                        
                    }
                }.onTapGesture {
                    self.url = i.url
                    self.show.toggle()
                }
            }.sheet(isPresented: self.$show){
                WebView(url: self.url)
            }.onAppear { UITableView.appearance().separatorStyle = .none }
        }
    }
}


class GetData : ObservableObject{
    
    @Published var data = [Book]()
    
    init() {
        
        let url = "https://www.googleapis.com/books/v1/volumes?q=harry+potter"
        let session = URLSession(configuration: .default)
        session.dataTask(with: URL(string: url)!) { (data, _, err) in
            if err != nil{
                print((err?.localizedDescription)!)
                return
            }
            
            let json = try! JSON(data: data!)
            let items = json["items"].array!
            
            for i in items{
                
                let id = i["id"].stringValue
                let title = i["volumeInfo"]["title"].stringValue
                let authors = i["volumeInfo"]["authors"].array!
                let description = i["volumeInfo"]["description"].stringValue
                let imgurl = i["volumeInfo"]["imageLinks"]["thumbnail"].stringValue
                let url = i["volumeInfo"]["previewLink"].stringValue
                
                var author = ""
                
                for j in authors{
                    author += "\(j.stringValue)"
                }
                
                DispatchQueue.main.async {
                    self.data.append(Book(id: id, title: title, authors: author, desc: description, imgurl: imgurl, url: url))
                }
                
            }
            
        }.resume()
    }
    
}

struct Book : Identifiable {
    
    var id : String
    var title : String
    var authors : String
    var desc : String
    var imgurl : String
    var url : String
    
}

struct WebView : UIViewRepresentable {
    
    var url : String
    
    func makeUIView(context: UIViewRepresentableContext<WebView>) -> WKWebView {
        
        let view = WKWebView()
        view.load(URLRequest(url: URL(string: url)!))
        return view
        
    }
    
    func updateUIView(_ uiView: WebView.UIViewType, context: UIViewRepresentableContext<WebView>) {
        
    }
    
}

