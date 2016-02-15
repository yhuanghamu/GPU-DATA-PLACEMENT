
knightPlace list = [if x == [] then [0] else x | x <-  kp list]
    where
    kp list = [[x | x <- [1..(length list)], safe x list i] | i <- [0..(length list) - 1]]
    safe x list i = (safeknight x list i) && (safequeens x list i)
    safeknight x list i = list!!i == 0 && and [not (checks x list i a) | a <- [0..(length list)-1]]
    checks x list i a = x == list!!a || (list!!a /= 0 && abs(a-i) == abs(list!!a - x))
    safequeens x list i = and [not (checks2 x list i a) | a <- [0..(length list)-1]]
    checks2 x list i a = list!!a /= 0 && (abs(i-a)*abs(x-list!!a) == 2) 
