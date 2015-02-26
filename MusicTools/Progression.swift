
class Progression {
    //return offset of chord root for various progressions
    class func blues12Bar() -> [Int] {
        return [0, 0, 0, 0, 5, 5, 0, 0, 7, 5, 0, 0]
    }
    class func circleProgression() -> [Int] {
        return [0, 5, 11, 4, 9, 2, 7, 0]
    }
    class func pachelbelCanon() -> [Int] {
        return [0, 7, 9, 4, 5, 0, 5, 7]
    }
    class func bach() -> [Int] {
        //http://www.hooktheory.com/theorytab/view/johann-sebastian-bach/jesus-bleibet-meine-freude?node=57%2F4.4#bridge
        return [0,0,5,7,2,4,5,7,0,7,7,7,   7,7,7,0,0,5,0,0,9,2,4,7,  0,0]
    }
}