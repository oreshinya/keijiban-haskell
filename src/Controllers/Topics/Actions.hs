module Controllers.Topics.Actions where

import Web.Spock
import Network.HTTP.Types.Status
import Database.MySQL.Simple
import qualified Controllers.Topics.Params as TP (Params(..), CheckedParams(..), validateParams)
import qualified Models.Topic as T (Topic(..), create, selectLatest)

create :: ActionCtxT ctx (WebStateM Connection sess st) a
create = do
    params <- jsonBody'
    case (TP.validateParams params) of
      (Left message) -> do
        setStatus status400
        json message
      (Right (TP.CheckedParams n)) -> do
        [Only i] <- runQuery $ T.create n
        setStatus status201
        json $ T.Topic i n

index :: ActionCtxT ctx (WebStateM Connection sess st) a
index = do
    xs <- runQuery T.selectLatest
    json $ map (\(i, n) -> T.Topic i n) xs
