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

struct ContentView: View {
    var body: some View {
        
        NavigationView{
            Home()
            .navigationBarTitle(Text("Books"))
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Home : View {
    
    @ObservedObject var books = GetData()
    
    var body : some View{
        List(books.data){i in
            Text(i.id)
        }
    }
}


class GetData : ObservableObject{
    
    @Published var data = [Book]()
    
    init() {
        
        let url = "https://www.googleapis.com/books/v1/volumes?q=java"
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
                let title = i["volumeInfo"]["title"]
                let authors = i["volumeInfo"]["authors"].array!
                
                
                DispatchQueue.main.async {
                    self.data.append(Book(id: id, title: "", authors: "", desc: "", imgurl: "", url: ""))
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
