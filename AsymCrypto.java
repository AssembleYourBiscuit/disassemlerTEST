
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
    
    public int extraCredit()
    {
        return 0;
    }
}
