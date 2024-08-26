({
    getRecordIdFromPageRef: function(pageRef) {
        var inContextOfRef = pageRef.state.inContextOfRef;
        var parts = inContextOfRef.split('.');
        
        if (parts.length < 2) {
            console.error('Invalid page reference format.');
            return null;
        }

        var base64Url = parts[1];
        var base64 = this.base64urlToBase64(base64Url);
        var decodedPayload = atob(base64);

        try {
            var payloadObj = JSON.parse(decodedPayload);

            if (payloadObj.attributes && payloadObj.attributes.objectApiName !== 'Contact') {
                return null;
            }
            
            return payloadObj.attributes ? payloadObj.attributes.recordId : null;
        } catch (e) {
            console.error('Error parsing payload:', e);
            return null;
        }
    },

    base64urlToBase64: function(base64Url) {
        return base64Url.replace(/-/g, '+').replace(/_/g, '/');
    }
})
