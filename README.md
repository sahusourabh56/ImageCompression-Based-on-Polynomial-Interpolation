# ImageCompression-Based-on-Polynomial-Interpolation

he Provided Code and Report contains comments and algorithm to fully explain the algorithm and the result

Fitting a polynomial curve in a distribution
	Any polynomial of degree n can represent as:
	y=∑_(n=1)^d▒〖C_n x^n 〗
	The original value at a point could be represented by y’ correspond to x, hence the total variance corresponding to error, over all the data points denoting the cost function can be represented with
	J=∑_(k=1)^N▒〖(y-y^' )^2=〗 ∑_(k=0)^K▒(∑_(n=0)^d▒〖C_n x^n 〗_n-y^' )^2 
	The Coefficients which would bring the least value of this cost function would be the one we would be considering to be the most accurate in representing the entire number series. Which we do by partially differentiating the cost function w.r.t. to each coefficient which is the variable here and equating it to 0:
	∂J/(∂C_n )=2*∑_(k=1)^K▒(∑_(n=0)^d▒〖C_n x_k^n 〗_n-y^' )x_k^  =0, for n∈1,d,
               ,2*∑_(k=1)^K▒(∑_(n=0)^d▒〖C_n x_k^n 〗_n-y^' )_^  =0, for n=1
	Now simplifying and arranging all the equations we will get,
M*C=N
	Where M, C, N are matrices of dimension (d+1) *(d+1), (d+1) *1, and (d+1)*1 respectively.




The challenge to image compression using regression with polynomial coefficients is storing the polynomial coefficients in as less space as possible. The double precision floating point numbers or floating-point numbers consume space at least 4 bytes.
This implies that if we are breaking a row into SN segments, each having FN fragments, the data for a single channel in one row should be 
	R=S_N*C*B, where C=D+1
	Where R = Total data in bytes of the in each row for each channel
	 Sn= Number of segments in each row
	 C = No of Coefficients
	 B = Total data required to store 1 coefficient
	 D = Degree of the polynomial which we are fitting inside the segment.
	Therefore, compression factor in each row, henceforth in each channel and image will be:
C.F. =〖(S〗_N*F_N)/(S_N*C*B), =F_N/(C*B) 
The Compression Factor (C.F.) of the image compression algorithm is given by:
	C.F. =〖(S〗_N*F_N)/(S_N*C*B), =F_N/(C*B)
Therefore, considering an example, where SN= 32 and FN= 16, with the degree of the polynomial being 4 compressed with a floating data type 4 bytes.
	C.F.=16/((4+1)*4)=0.8<1
This is an undesirable trait as we see even after the operation, we couldn’t achieve any compression. To increase the C.F., we may reduce the degree of the polynomial or increase the size of the fragment.  If FN is increased, the curve must be fitted between more data points. Hence reducing accuracy, decreasing S.N.R
If C corresponding to the degree of the polynomial is reduced, the polynomial becomes less sensitive to data variations, hence decreasing accuracy and S.N.R. So, we require to reduce the number of bytes required to store one coefficient of a polynomial from 4 bytes to less, with as much accuracy as possible.   
This is achieved with a 2byte data compressing method working with the given approach, which provides accuracy within 0.5% data limit:
	Logarithmic function is used to extract the exponent of the number by taking the floor of the logarithmic result.
	2 is added to the negative of the exponent and it is multiplied to the number to, as a result we get the 3MSDs in 100s 10s and 1s place.
	We check if the 4MSD is larger than 5, if yes, we increment the number by 1.
	Floor function is used to separate the part after decimal and 100s and 10s place number are extracted by diving by 10 stored as couple, and the 1s place is extracted by performing a modulo operation on the number with 10.
	A bias of 20 is added to the exponent, therefore if degree is -13, the exponent after added with 20 gives 7.
	If the number is lesser than 0, we set the sign bit to 1.
	The resultant 3 numbers, are stored in the following format:
	The 100s place of byte 1, having range 0-255, i.e., the 100s place will store the sign bit (0 or 1).
	The 10s and 1s places together will store the most significant and second most significant digit of the number (00-99).
	The 100s and 10s place of byte 2, will store the exponent added with bias, (0-24).
	The 1s place of byte 2 will store the third most significant digit.   
These 2byte entries are stored in place of standard double or floating-point data types, thereby reducing the size of the compressed data by at least half.
