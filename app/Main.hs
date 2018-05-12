{-# LANGUAGE NoMonomorphismRestriction #-}
{-# LANGUAGE FlexibleContexts          #-}
{-# LANGUAGE TypeFamilies              #-}

module Main where

import Lib
import Diagrams.Prelude
import Diagrams.TwoD.Polygons
import Diagrams.Backend.SVG
import Diagrams.TwoD.Size


rotate ::Int ->  [a] -> [a]
rotate _ [] = []
rotate n xs = zipWith const (drop n (cycle xs)) xs 


sizE :: SizeSpec V2 Double
sizE = dims2D 800 800


rawPolygon :: Diagram B
rawPolygon =  polygon $ PolygonOpts (PolyRegular 6 4) OrientV origin


t :: [Diagram B]
t =  map (\x -> rawPolygon # fc x) [black, white, red]


topLeftHex :: Diagram B -> Diagram B
topLeftHex = snugT . snugL


topRightHex :: Diagram B -> Diagram B
topRightHex = snugT . snugR


xx :: Diagram B -> Diagram B
xx = snugL . alignB 


hexadd :: (Diagram B, Int) -> [Diagram B] -> (Diagram B, Int)
hexadd (mempty, 0) x = (xx . hcat $ x , length x) 
hexadd (top,pcount) bottom = let gradient = length bottom > pcount
                                 ff = if gradient 
                                         then topRightHex
                                         else topLeftHex                                        
                                 nbottom = hcat . map ff $ bottom
                             in ((top <> nbottom) # xx, length bottom)


gengen :: Int -> Int -> [[Diagram B]]
gengen minm maxm = let a = [minm .. maxm] ++ reverse [minm..maxm-1]
                       b = [0 .. (maxm - minm)]
                       c = b ++ (reverse . init $ b)
                   in map (\(x,y) -> take y . cycle $ Main.rotate x t) (zip c a)



chessboard :: Diagram B
chessboard = fst . foldl hexadd (mempty,0) $ gengen 34 50


main :: IO ()
main = renderSVG "hello2.svg" sizE chessboard
