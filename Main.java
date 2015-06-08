package pkg430hw;


public class Main
{
    public static void main(String[] args)
    {
        String str = "the quick brown fox jumps over the lazy dog";
        AsymCrypto cry = new AsymCrypto(7, 13, 29, 5);
        String crypted = "";
        String decry = "";
        
        System.out.print("String to encrypt: " + str + "\n");
        System.out.print("Encryped String: ");
        for(int i = 0; i < str.length(); i++)
        {
            
            crypted += cry.encrypt(str.charAt(i));
        }
        System.out.println(crypted);
        
        for(int i = 0; i < crypted.length(); i++)
        {
            int ascii = Integer.parseInt(crypted.substring(i, i + 2));
            String thisChar = Character.toString((char) ascii);
            decry += thisChar;
        }
        System.out.println("Decrypted string: " + decry);
    }
}
