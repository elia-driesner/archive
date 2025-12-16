import time
from django.http import HttpResponse, JsonResponse

from agora_token_builder import RtcTokenBuilder

def getExpireTime():
    currentTimestamp = int(time.time())
    privilegeExpiredTs = currentTimestamp + 86400
    return privilegeExpiredTs

def generateToken(response):
    data = response.GET;
    
    token = RtcTokenBuilder.buildTokenWithUid(
        data['appId'], 
        data['appCertificate'], 
        data['channelName'], 
        data['uid'], 
        1, 
        getExpireTime()
    )

    return JsonResponse({'token': token});