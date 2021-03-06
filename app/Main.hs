{-# LANGUAGE OverloadedStrings #-}
module Main where

import           Controllers.Comments.Actions         as CC
import           Controllers.Topics.Actions           as CT
import           Database.MySQL.Simple
import           Network.Wai.Middleware.Cors
import           Network.Wai.Middleware.RequestLogger
import           Web.Spock
import           Web.Spock.Config

openDBConnection :: IO Connection
openDBConnection = connect defaultConnectInfo
  { connectDatabase = "keijiban"
  , connectHost = "db"
  , connectPassword = "password"
  }

closeDBConnection :: Connection -> IO ()
closeDBConnection = close

dbConnectionBuilder :: ConnBuilder Connection
dbConnectionBuilder = ConnBuilder openDBConnection closeDBConnection (PoolCfg 1 1 30)

appCfg :: IO (SpockCfg Connection () ())
appCfg = defaultSpockCfg () (PCConn dbConnectionBuilder) ()

app :: SpockM Connection () () ()
app = do
    post "topics" CT.create
    get "topics" CT.index
    post ("topics" <//> var <//> "comments") CC.create
    get ("topics" <//> var <//> "comments") CC.index

main :: IO ()
main = do
    spockCfg <- appCfg
    runSpock 8080 $ ((logStdoutDev . simpleCors).) <$> spock spockCfg app
