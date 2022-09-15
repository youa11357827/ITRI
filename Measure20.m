clear;
close all;

ImgOrigin = imread('E:\MatlabTest\Week1\Picture\20.bmp');
TrueSize = 7.8125;

PixelSize = 6.45;
Amplify = 20;

NewPicRow = 40;
NewPicColumn = 130;

OldPicRowShift = 232;
OldPicColumnShift = 365;

NewPixelSize = PixelSize/Amplify; 
ImgGray=rgb2gray(ImgOrigin);


ImgSplit = ImgGray(OldPicRowShift+1: OldPicRowShift+NewPicRow, OldPicColumnShift+1: OldPicColumnShift+ NewPicColumn);

for Row = 1:NewPicRow
	for Column = 1:NewPicColumn
        if (Row == 1) || (Row == NewPicRow) || (Column == 1) || (Column == NewPicColumn)
            ImgGray(Row+OldPicRowShift,Column+OldPicColumnShift) = 0;
        end
	end
end

figure,imshow(ImgGray);
figure,imshow(ImgSplit);

sigma = 1;
gausFilter=fspecial('gaussian',[5 5],sigma);
ImgFilter= imfilter(ImgSplit, gausFilter, 'replicate');

ImgEdge = edge(ImgFilter,'Canny',0.1);

ImgFill=imfill(ImgEdge,'holes');   

ImgFillEdge=bwperim(ImgFill);

LeftCenter = [];
TopCenter = [];

%------------------------------------ Run Column First / Get Width
LeftSum = 0;
BreakFlag = 0;
for Row = 1:NewPicRow
    for Column = 1:NewPicColumn
        if ImgFillEdge(Row,Column) == 1
            LeftSum = sum(ImgFillEdge(:,Column));
            
        end
        if LeftSum > 3
            LeftCenter(1) = Row + floor(LeftSum/2);
            LeftCenter(2) = Column;
            BreakFlag = 1;
            break;
        end
    end
    if BreakFlag == 1
        break;
    end
end

for Column = LeftCenter(2) + 1:NewPicColumn
    if ImgFillEdge(LeftCenter(1), Column) == 1
        WidthPixelLength = Column - LeftCenter(2) + 1;
   
    end
end
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Run Column First / Get Width

%------------------------------------ Run Row First / Get high
TopSum = 0;
BreakFlag = 0;
for Column = 1:NewPicColumn
    for Row = 1:NewPicRow
        if ImgFillEdge(Row,Column) == 1
            TopSum = sum(ImgFillEdge(Row,:));
            
        end
        if TopSum > 5
            TopCenter(1) = Row;
            TopCenter(2) = Column + floor(TopSum/2);
            BreakFlag = 1;
            break;
        end
    end
    if BreakFlag == 1
        break;
    end
end

for Row = TopCenter(1) + 1:NewPicRow
    if ImgFillEdge(Row, TopCenter(2)) == 1
        HighPixelLength = Row - TopCenter(1) + 1;
    end
end
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Run Row First / Get high


WidthLength = WidthPixelLength * NewPixelSize;

HighLength = HighPixelLength * NewPixelSize;
MeasureResult = ['Measure Length: ',num2str(HighLength), ' um'];
TrueSizeResult = ['   True Length: ',num2str(TrueSize), ' um'];
disp(MeasureResult);
disp(TrueSizeResult);
figure,imshow(ImgFillEdge);
