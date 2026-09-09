const { onDocumentWritten } = require('firebase-functions/v2/firestore');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');

initializeApp();

exports.sendIncomingCallPush = onDocumentWritten('callInvites/{calleeId}', async (event) => {
  const before = event.data.before.exists ? event.data.before.data() : null;
  const after = event.data.after.exists ? event.data.after.data() : null;

  if (!after || after.status !== 'ringing') return;
  if (before && before.status === 'ringing') return;

  const calleeId = event.params.calleeId;
  const calleeSnap = await getFirestore().collection('users').doc(calleeId).get();
  const token = calleeSnap.exists ? calleeSnap.data().fcmToken : null;
  if (!token) return;

  const isVideoCall = after.mediaType === 'video';

  const message = {
    token,
    notification: {
      title: isVideoCall ? 'Incoming video call' : 'Incoming audio call',
      body: after.callerName || 'ConnectCall',
    },
    data: {
      type: 'incoming_call',
      callId: after.callId || '',
      callerId: after.callerId || '',
      callerName: after.callerName || '',
      mediaType: after.mediaType || 'audio',
      calleeId,
    },
    android: {
      priority: 'high',
      notification: {
        channelId: 'connectcall_incoming_calls',
        priority: 'max',
      },
    },
    apns: {
      headers: {
        'apns-priority': '10',
      },
      payload: {
        aps: {
          contentAvailable: true,
          sound: 'default',
        },
      },
    },
  };

  try {
    await getMessaging().send(message);
  } catch (error) {
    console.error('sendIncomingCallPush failed', error);
  }
});
