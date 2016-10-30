{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Main where

import Web.Spock
import Web.Spock.Config
import Database.MySQL.Simple
import GHC.Generics (Generic)
import Data.Aeson hiding (json)

data RequestedTopic = RequestedTopic { val :: String } deriving (Generic, Show)
data Topic = Topic { id :: Int, name :: String } deriving (Generic, Show)

instance FromJSON RequestedTopic
instance ToJSON Topic

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
    post "topics" $ do
      (RequestedTopic n) <- jsonBody'
      [Only i] <- runQuery $ \conn -> do
        execute conn "INSERT INTO topics (name) VALUES (?)" [n]
        query_ conn "SELECT LAST_INSERT_ID()"
      json $ Topic i n


main :: IO ()
main = do
    spockCfg <- appCfg
    runSpock 8080 (spock spockCfg app)
