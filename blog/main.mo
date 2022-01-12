import Array "mo:base/Array";   
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
actor{
    public type Message ={
        msgtext : Text;
        msgtime : Time.Time;
    };

    private type Microblog = actor{
        follow : shared(Principal) -> async();
        follows : shared query () -> async [Principal];
        post : shared(Text) -> async ();
        posts : shared query (Time.Time) -> async [Message];
        timeline : shared(Time.Time) -> async [Message];
    };

    var followed : List.List<Principal> = List.nil();

    public shared func follow(id : Principal) : async (){
        followed := List.push(id,followed);
    };

    public shared query func follows() : async [Principal] {
        List.toArray(followed)
    };

    var messages : List.List<Message> = List.nil();

    public shared func post(text : Text ) : async (){
        var p : Message = {
            msgtext = text;
            msgtime = Time.now();
        };
        messages := List.push(p, messages);
    };

    public shared query func posts(since: Time.Time) : async [Message] {
        var postslist : List.List<Message> = List.nil();

        for(msg in Iter.fromList(messages)){
            if(msg.msgtime >= since){
                postslist := List.push(msg,postslist);
            };
        };
        List.toArray(postslist)
    };

    public shared func timeline(since: Time.Time) : async [Message] {
        var all : List.List<Message> = List.nil();

        for(id in Iter.fromList(followed)) {
            let canister : Microblog = actor(Principal.toText(id));
            let msgs = await canister.posts(0);
            for(msg in Iter.fromArray(msgs)) {
                if(msg.msgtime >= since){
                    all := List.push(msg,all);
                };
            }
        };

        List.toArray(all)
    };
}