module Controllers.Comments.Actions where

import Control.Monad.IO.Class
import Web.Spock
import Network.HTTP.Types.Status
import Database.MySQL.Simple
import qualified Controllers.Comments.Params as CP (Params(..), CheckedParams(..), validateParams)
import qualified Models.Comment as C (Comment(..), create, selectByTopicId)

create :: Int -> ActionCtxT ctx (WebStateM Connection sess st) a
create topicId = do
    params <- jsonBody'
    case (CP.validateParams params) of
      (Left message) -> do
        setStatus status400
        json message
      (Right (CP.CheckedParams b)) -> do
        setStatus status201
        [Only i] <- runQuery $ C.create topicId b
        json $ C.Comment i topicId b

index :: Int -> ActionCtxT ctx (WebStateM Connection sess st) a
index topicId = do
    xs <- runQuery $ C.selectByTopicId topicId
    json $ map (\(i, t, b) -> C.Comment i t b) xs
