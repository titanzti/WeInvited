const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
const database = admin.firestore();
var newData;

exports.onCreatenewData = functions.firestore
    .document('JoinEvent/{JoinEventId}/JoinEventList/{JoinEventListId}')
    .onCreate(async (snapshot, context) => {

        if (snapshot.empty) {
            console.log("No token for user, can not send notification.")
        }

        
        newData = snapshot.data();
        var tokens = [newData.token];

        if (!snapshot.empty) {
            console.log(newData.receiveremail)
        }
        let body;
        switch(newData.status){
           
            case 'request':
                body = `${newData.userID} has requested to follow you`; 
                break;
            
            case 'compatibility':
                body = `${newData.userID} wants to do a quiz with you`;
                break;
            
              default:
               break;
        } 

        
        var payload = {
            notification: { title: `Flutter Chat App | ${newData.senderName}`, body: body ,sound: 'default' },
            data: {
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
                message: body,
            },
        };
        try {
            const response = admin.messaging().sendToDevice(tokens, payload);
            console.log('Nofication sent successfully');
        } catch (err) {
            console.log('error sending notificaiton');

        }



    });


exports.test= functions.firestore
.document('JoinEvent/{JoinEventId}/JoinEventList/{JoinEventListId}')
.onCreate(async(snapshot,context)=>{

    if (snapshot.empty) {
        console.log("No token for user, can not send notification.")
    }

        // var tokens=[];
        // tokens.push(snapshot.data().token);

        const JoinEvent = snapshot.data();

        if (!snapshot.empty) {
            console.log(JoinEvent.receiveremail)
        }

        const querySnapshot = await database
            .collection('userData')
            .doc(JoinEvent.receiveremail)
            .collection('tokens')
            .get();
            console.log(`querySnapshot | ${querySnapshot}`);


        const tokens = querySnapshot.docs.map(snap => snap.id);

        console.log(`tokens | ${tokens}`);

        var payload={notification: {title: ` ${JoinEvent.senderName}: has requested to event  you `,body:'body',sound: 'default'},
        data: {click_action: 'FLUTTER_NOTIFICATION_CLICK'}}

        const response=await admin.messaging().sendToDevice(tokens,payload)
    }
);