print ("               Display Name : ", MOAIEnvironment.appDisplayName)
print ("                     App ID : ", MOAIEnvironment.appID)
print ("                App Version :  ", MOAIEnvironment.appVersion)
print ("            Cache Directory : ", MOAIEnvironment.cacheDirectory)
print ("   Carrier ISO Country Code : ", MOAIEnvironment.carrierISOCountryCode)
print ("Carrier Mobile Country Code : ", MOAIEnvironment.carrierMobileCountryCode)
print ("Carrier Mobile Network Code : ", MOAIEnvironment.carrierMobileNetworkCode)
print ("               Carrier Name : ", MOAIEnvironment.carrierName)
print ("            Connection Type : ", MOAIEnvironment.connectionType)
print ("               Country Code : ", MOAIEnvironment.countryCode)
print ("                    CPU ABI : ", MOAIEnvironment.cpuabi)
print ("               Device Brand : ", MOAIEnvironment.devBrand)
print ("                Device Name : ", MOAIEnvironment.devName)
print ("        Device Manufacturer : ", MOAIEnvironment.devManufacturer)
print ("                Device Mode : ", MOAIEnvironment.devModel)
print ("            Device Platform : ", MOAIEnvironment.devPlatform)
print ("             Device Product : ", MOAIEnvironment.devProduct)
print ("         Document Directory : ", MOAIEnvironment.documentDirectory)
print ("         iOS Retina Display : ", MOAIEnvironment.iosRetinaDisplay)
print ("              Language Code : ", MOAIEnvironment.languageCode)
print ("                   OS Brand : ", MOAIEnvironment.osBrand)
print ("                 OS Version : ", MOAIEnvironment.osVersion)
print ("         Resource Directory : ", MOAIEnvironment.resourceDirectory)
print ("                 Screen DPI : ", MOAIEnvironment.screenDpi)
print ("              Screen Height : ", MOAIEnvironment.screenHeight)
print ("               Screen Width : ", MOAIEnvironment.screenWidth)
print ("                       UDID : ", MOAIEnvironment.udid)

PLATFORM = MOAIEnvironment.osBrand
if PLATFORM=="Linux" and MOAIEnvironment.osVersion==nil and MOAIEnvironment.devPlatform==nil and MOAIEnvironment.devName==nil then
  -- Nacl?
  -- testing if I can write file
  local file = io.open ( "NaClFileSys/test.txt", 'wb' )
  if file == nil then
  	--maybe Linux
  else
    PLATFORM = "Nacl"
    print ("forced platform : "..PLATFORM)
    file:write ( "test" )
    file:close ()
  end
end
-- Load specific Platform settings...
if  MOAIFileSystem.checkFileExists ("is"..PLATFORM..".lua") then
  require ("is"..PLATFORM)
end