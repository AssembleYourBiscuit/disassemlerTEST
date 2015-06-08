
package pkg430hw;

public class AsymCrypto
{
    int p, q, kd, ke, n;
    
    public AsymCrypto(int p, int q, int kd, int ke)
    {
        this.p = p;
        this.q = q;
        this.kd = kd;
        this.ke = ke;
        this.n = p*q;
    }
    
    public int encrypt(int m)
    {
        return  (int) (Math.pow(m, ke) % n);
    }
    
    public int decrypt(int m)
    {
        return (int) (Math.pow(m, kd) % n);
    }
    
    public int extraCredit(int p, int q, int ke)
    {
        int thisNum = (p - 1) * (q - 1);
        int max = 100;
        for (int i = 1; i < max; i++) 
        {
            boolean isPrimeNumber = true;
            for (int j = 2; j < i; j++) 
            {
                if (i % j == 0) {
                    isPrimeNumber = false;
                    break; 
                }
            }
            if (isPrimeNumber) 
            {
                if(i * ke % thisNum == 1)
                {
                    return i;
                }
            }
        }
        return -1;
    }
       
    
}
