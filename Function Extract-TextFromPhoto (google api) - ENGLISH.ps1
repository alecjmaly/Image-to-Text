# Example :  Extract-TextFromPhoto -Path C:\Users\alecm\Desktop\people3.jpg -language "en" -returnType Text



function Extract-TextFromPhoto {
    Param(
        [parameter(Mandatory=$true)]
        [String] $Path,
        [parameter(Mandatory=$false)]
        [String[]] $language,
        [ValidateSet('Text', 'Full Response')]
        [String[]] $returnType
    )   

    $googleAPIkey = 'AIza...YJ_bs'
    $base64 = [convert]::ToBase64String((get-content $Path -encoding byte))

    if ($language) {
        $languageQuery = ', 
              "imageContext": {  
                "languageHints": [
                    "{0}"
                ]
              }'.replace('{0}', $language)
    } else {
        $lauguageQuery = "";
    }


    $body = '{
      "requests": [
        {
          "image": {
            "content": "{0}"
          },
          "features": [
            {
              "type": "DOCUMENT_TEXT_DETECTION"
            }
          ]{1}

        }
      ]
    }'.replace("{0}", $base64).replace("{1}", $languageQuery)

    $response = Invoke-WebRequest -ContentType "application/json" -method post -uri "https://vision.googleapis.com/v1/images:annotate?key=$googleAPIKey" -Body $body

    $shortResponse = ($response.Content | ConvertFrom-Json).responses

    if ($returnType -eq "Full Response") {   
        return $response
    } else {
        $responseObj = $response.Content | ConvertFrom-Json
        return $responseObj.responses.fullTextAnnotation.text
    }    
}
