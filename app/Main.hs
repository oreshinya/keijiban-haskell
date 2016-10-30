module Main where

import Web.Spock
import Web.Spock.Config
import Database.MySQL.Simple

openDBConnection :: IO Connection
openDBConnection = connect defaultConnectInfo { connectDatabase = "keijiban" }

closeDBConnection :: Connection -> IO ()
closeDBConnection = close

dbConnectionBuilder :: ConnBuilder Connection
dbConnectionBuilder = ConnBuilder openDBConnection closeDBConnection (PoolCfg 1 1 30)

appCfg :: IO (SpockCfg Connection () ())
appCfg = defaultSpockCfg () (PCConn dbConnectionBuilder) ()

app :: SpockM Connection () () ()
app = do
    get root $
      json "Hello world"

main :: IO ()
main = do
    spockCfg <- appCfg
    runSpock 8080 (spock spockCfg app)
