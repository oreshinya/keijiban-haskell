{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Main where

import Web.Spock
import Web.Spock.Config
import Database.MySQL.Simple
import qualified Topic as T (Topic(..), RequestedTopic(..))

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
    get "topics" $ do
      xs <- runQuery $ \conn -> do
        query_ conn "SELECT id, name FROM topics ORDER BY id DESC"
      json $ map (\(i, n) -> T.Topic i n) xs

    get ("topics" <//> var) $ \(x :: Int) -> do
      t:ts <- runQuery $ \conn -> do
        query conn "SELECT id, name FROM topics WHERE id = ?" [x]
      json $ T.Topic (fst t) (snd t)

    post "topics" $ do
      (T.RequestedTopic n) <- jsonBody'
      (Only i:_) <- runQuery $ \conn -> do
        execute conn "INSERT INTO topics (name) VALUES (?)" [n]
        query_ conn "SELECT LAST_INSERT_ID()"
      json $ T.Topic i n

main :: IO ()
main = do
    spockCfg <- appCfg
    runSpock 8080 (spock spockCfg app)
