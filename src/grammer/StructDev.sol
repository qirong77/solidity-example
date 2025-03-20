// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.2 <0.9.0;

contract StructDev {
    struct SStudent {
        int id;
        int score;
    }
    SStudent s1;
    function initStruct() external returns(SStudent memory){
        s1.id = 0;
        s1.score = 10;
        s1 = SStudent({id: 1, score: 2});
        SStudent memory s2 = SStudent({id: 2, score: 20});
        return s2;
    }
}
