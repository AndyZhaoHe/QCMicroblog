import Text "mo:base/Text";
import List "mo:base/List";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Int "mo:base/Int";

actor QCMicroblog {

    public type Message = {
      text: Text;
      time : Int;
    };
   
    public type Microblog = actor {
       follow : shared(Principal) -> async();// 添加关注对象
       follows : shared query () -> async [Principal]; // 返回关注列表
       post : shared(Text) -> async(); // 发布消息
       posts : shared query (Time.Time) -> async [Message]; // 返回所有发布的消息
       timeline : shared(Time.Time) -> async [Message] // 返回所关注对象发布的消息
    };

    
   stable var followed : List.List<Principal> = List.nil();

    public shared func follow(id: Principal) : async () {
         followed := List.push(id, followed);
    };

    public shared func follows() : async [Principal] {
           List.toArray(followed);
    };

    stable var messages : List.List<Message> = List.nil();


     public shared(msg) func post(text: Text) : async () {
          assert(Principal.toText(msg.caller) == Principal.fromActor(QCMicroblog));
         let m1 = {
             text = text;
             time = Time.now();
         };
         messages := List.push(m1, messages);
         
    };

     public shared func posts(since : Time.Time) : async [Message] {
        
        var posts : List.List<Message> = List.nil();

         for(message in Iter.fromList(messages)) {
             if (message.time >= since) {
                 posts := List.push(message, posts);
             }
         };
          
        List.toArray(posts);
    };

     public shared func timeline(since : Time.Time) : async [Message]{
          var all : List.List<Message> = List.nil();
         
           for (id in Iter.fromList(followed)) {
                let canister : Microblog = actor(Principal.toText(id));
                let msgs = await canister.posts(since);
                for (msg in Iter.fromArray(msgs)) {
                  all :=  List.push(msg, all);
                }
         };

          List.toArray(all);
    };
};