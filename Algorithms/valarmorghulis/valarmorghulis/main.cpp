//
//  main.cpp
//  valarmorghulis
//
//  Created by ALEXANDROS-CHARALAMPOS KYPRIANIDIS on 26/8/16.
//  Copyright © 2016 ALEXANDROS-CHARALAMPOS KYPRIANIDIS. All rights reserved.
//

#include <iostream>
#include <string>

using namespace std;

int main(int argc, const char * argv[]) {
    string s1,s2;
    long int l1,l2;
    long int **C;
    s1 = "IVDGUTWEXMPVBLKHFLUCNDWCDJSMIXLFSTIXYPSRRFOCXFWXTGYAQVIPCRLEIMJBLHPJTTRJPBXNGFLFNIKSFWIMXJKOMJTDTOACYHVRNWQNPQZWJDQNUKLBMYBWZOVHYMWTQHUSNSGOREJLYWBFGRTYLKTJEMUEKOXSMPSDJZGHUAPHMHTEJDQAHINHIFQUGUINCBXXVTBDLBTSCRVMCIEZFMKIMUTYHQJJUZAXVEFDPJPNDNNVUIGMCXTXHEGQJNFOSKBQLYKKYRLSRJAFXKXWBDPZFUXCHXFSUHSCXPBVTAIGUTCFAQSXCLHLXFJUGSJVYEKFOIMQLTALFTIENAGWAQMIIGKVIKAXXBZEQMTBGPZGLQISAJELACPVHNDNIVISTDUJZHZIZUKISDCEGITPXXWRXNSMGMDMAGMMPJVOSAXPYUBQNMCDCDJSAACWLWWCRISQDQZZVEWUVMECTUPPKLXSGNKVWWJVNYRLISKJEUQFSGERNIPJVZUXZUMOCWPUVDCCJQPPPCPQLRMDZSRDSWCLCNXVHLPAJKBHMBYGVPNHCSEJXGYKMQAFLDERHIQRTNQBWCLKPRENPDBDARSTZQGQYRKDPKJADOARTWUFSTLOIEFCARMJYGXPJLPHKWSXJWKIXNOBUPNKYDWIEORUGKDMNCUDWUIIKTBQROGBPZNIJBHISQENNODCKOYDBMOMRNZDMRFWLRRWPZWQOIRVYSYECBEYEYFDQBYIKSIUMMPPSVRSEKIIFSMGLYZMXDHTMXQTDKKEVKXCHWTKDGCXFNTZMJMPGYCSEWLMHSUYEPNZNHEEPTDFIXROVZOUBRSRTBKIKKQGRHHSAYXNYZZCDPEVQRXJUVKWLVPEKNSXTXRXRJZMMBYGRRPAWDYZIWTMSDZZWRICJQKDKHMPEHYCEMWULXSRVBDVQVVRXYEMDOPQULESNPTDBFWHXEOIZDIAZIGTBSSGWYIMRZFDGIPDWLROMPYSPYTJCSTARJWENIRPBGFHVERWFFJWXTKQETWAPTSQRPWUESKTJJUHWMQGHCNXYAJABGCJXNPSZMHRKUJGGQHWYXVHLPBBVIUWIMFOIDMBBKRDDPWDPIXWZZLGIBONAHAAIAKJIEDNFYBBQZXBDPEKSFKBLWXBXXORGGIXWBHTARAKLGINODREAGGKLOFWMVVSLGEVZIWDUAMQAYPXBKUHSBNGRGGFDWRFBDGWDBBJJGERHQWCKUQWGWTSWWWCCFQOAUGLZIHSWLSKPCDPDUAMBILZNKFIUYTWXLCYAWNOEWWZQXTKHVWOUVPNYIIIPJTJGTZDFDSCLPWSZSWJZRLQPFURSQMBSMVWBORDLPUNDVIYHKTGRIKLZSXYFGRXPKJCEBAXTYYUKQWZNCNXZDSJHSIZKNGCEDYNZHAKNWZWAAIRSZVBXWBHLMOOZNOBICAYABVELUISYMDRUQDWRKCEOQFARJ";
    s2 = "DNGRUGWEXIOPRBPLKHLUCDDCUDCJUMHILYSLQRYPTENROCXFZTGYAQVAICRRLEUMJBLHPJOTTRPEBXNGFLFNHIFJWIXJKOMJIYTOQAQCYURNQANOPQZWJFQONUKLMBMYEBZYLVRJMWTQHTTENLGOREJYEWSBYRHCTLKTJEXUKOXSMKSLJZWFZKUKPYMHVEJDGAHMZIVNHGUIXWCBXRXVFBLBTSCVIEUZKIMUPYHQDPJMJUQZXVMFPJPCJNDONNVVIGMUCXIDTXJGQJNFPSKQLKKYBLISIRJAFXKXWBUPBFUXCDXYNSUHPDCXMHNVTAIGUPCFIQSNCLHFCQUGSJYTKFOIHLTTLFIEHAGAOQMIIGFVAKAXPQZEQMTZGPIZGQIQOIJENOCFVHXMNUNHIJVQSTODUJGZIMHKIJDMQEGTKPKXWPXIWXXNSMGMMOGMMPJJFONJSAXPBQNMCDCASXAICWLWJWCRLDQZZVEWEUVMECTUMIGPKXSXGNVGWWLITSKJUQFSGCRNDECVJVZUXZREUMWRWPUVDCCJQPPABPHPQHTRDDZROSSWCDNCLNVHLPJBKBSBYGVPNHCUNJXGPKMQAFLDHEQRNQBLKPRENPDBRSTTZQZGQTYRKDPWJPHTWISTFLJIEFAGQRKYGKXNPJUHKWHXJWHFTQSOBUPNJYDNIBEORVGKDMNCDUIIXKOTHRQROPFZNIJBIKEHNPXDAKOVDYBMOKRVMBRNWMRWLRRWPZWQOPIVGYSHEBCJYIYDBYKSISMMMPPFJVSEDFIIFSOMGOZMXDETMBOQTDKGYETKXWDHKPTQKDCAXNZMJMGYCSELMSUYEPNLNHPTDPJXVNHHZOUBRSRBSOKKQGKRHHVZSBAYXZGZCDDPQRJUXWMLVCEMKTSCXAMTXRXRJJZMMBGRRLTXAWYYLUWQMSDZJCPZWRTICJKKMPBHYYEWQIULXSRVJZVQVDSYEOPULESNPKDBFWVHXZOIZWIZIRGTBSBGLYIMRZTDQGIPDWLOMLYSYTJCKSTARJWANIEFHFHVEUCRGWSFJEXIWAPZTQYPWUGGSXTJJIUHNOWMQGQZCNXAJAMGCQJXNMHVFRUJGQHWYXHLDBBBZFIZUTIHHIQMBBKPDIPWPIRXILZVLGIBOAHKJAKJIWDNSYABQZWDPEKFQKLJVWXBHXOEGGIXAWHTARAJULGYINADRMAGKLINFWHMVWVSGMGVYTZIRDUAQAEHBKUHWMNGDRGHSGFDWRBDGDBWVBJZJGEHHWCKBUYGTWTBWWWQAFABUGLZHSLUTZQUPHODUSAMPBYIWLZSNIUAYTWVLQATWNOEWLWQXTXHVWOUVPYIIIYJAJGTZPHSVLANTWSZSWJZTFQPFRJSVQSMVPHBQKDLPUGNDVIIYHTGXWKNQLZSTXBFVGRXPKCGBNXTRTGXUEQWSZCNXVSZHSIZKDCEDUYNZHAKNWCYZWAKWAHZVBXXWBHLMOOZXOBICAYABELUISYMDRQJQDWRKCEOQFARJ";
    l1 = s1.length();
    l2 = s2.length();
    
    C = (long int **)malloc((l1+1)*sizeof(long int *));
    for(int i = 0;i<= l1;i++){
        C[i] = (long int *)malloc(sizeof(long int)*(l2+1));
    }
    for(int i = 0;i <= l1;i++){
        C[i][0] = i;
    }
    for(int j = 0;j <= l2;j++){
        C[0][j] = j;
    }
    for(int i = 1;i <= l1;i++){
        for(int j = 1;j <= l2;j++){
            if(s1[i-1] == s2[j-1]){
                C[i][j] = C[i-1][j-1];
            }else{
                if((C[i-1][j] + 1 < C[i][j-1] + 1)&&(C[i-1][j] +1 < C[i-1][j-1] + 1)){
                    C[i][j] = C[i-1][j] + 1;
                }else if((C[i][j-1] + 1 < C[i-1][j] + 1)&&(C[i][j-1] + 1 < C[i-1][j-1] + 1)){
                    C[i][j] = C[i][j-1] + 1;
                }else{
                    C[i][j] = C[i-1][j-1] + 1;
                }
            }
        }
    }
    
    
    cout<<C[l1][l2]<<endl;
    return 0;
}
