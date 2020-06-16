const functions = require('firebase-functions')
const admin = require('firebase-admin')
admin.initializeApp()

exports.sendNotification = functions.firestore
  .document('messages/{groupId1}/{groupId2}/{message}')
  .onCreate((snap, context) => {
    console.log('----------------start function--------------------')

    const doc = snap.data()
    console.log(doc)

    const idFrom = doc.idFrom
    const idTo = doc.idTo
    const contentMessage = doc.content

    // Get push token user to (receive)
    admin
      .firestore()
      .collection('users')
      .where('uid', '==', idTo)
      .get()
      .then(querySnapshot => {
        querySnapshot.forEach(userTo => {
          console.log(`Found user to: ${userTo.data().email}`)
          console.log(`To Pushtoken: ${userTo.data().pushToken}`)
          console.log(`to Chatting: ${userTo.data().chattingWith}`)
          console.log(`ID From : `+idFrom)
          if (userTo.data().pushToken && userTo.data().chattingWith !== idFrom) {
            // Get info user from (sent)
            admin
              .firestore()
              .collection('users')
              .where('uid', '==', idFrom)
              .get()
              .then(querySnapshot2 => {
                querySnapshot2.forEach(userFrom => {
                  console.log(`Found user from: ${userFrom.data().email}`)
                  const payload = {
                    notification: {
                      title: `Anda Mendapatkan Pesan Dari : "${userFrom.data().email}"`,
                      body: contentMessage,
                      badge: '1',
                      sound: 'default'
                    },
                    data: {
                      click_action: "FLUTTER_NOTIFICATION_CLICK",
                      peer_id: doc.idFrom,
              
                    }
                  }
                  // Let push to the target device
                  admin
                    .messaging()
                    .sendToDevice(userTo.data().pushToken, payload)
                    .then(response => {
                      console.log('Successfully sent message:', response)
                    })
                    .catch(error => {
                      console.log('Error sending message:', error)
                    })
                })
              })
          } else {
            console.log('Can not find pushToken target user')
          }
        })
      })
    return null
  })