{-# LANGUAGE OverloadedStrings #-}
module Main where

import Web.Spock
import Web.Spock.Config
import Network.Wai.Middleware.RequestLogger
import Network.Wai.Middleware.Cors
import Database.MySQL.Simple
import Controllers.Topics.Actions as CT
import Controllers.Comments.Actions as CC

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
    post "topics" CT.create
    get "topics" CT.index
    post ("topics" <//> var <//> "comments") CC.create
    get ("topics" <//> var <//> "comments") CC.index

main :: IO ()
main = do
    spockCfg <- appCfg
    runSpock 8080 $ ((logStdoutDev . simpleCors).) <$> spock spockCfg app
