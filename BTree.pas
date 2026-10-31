unit BTree;

interface

uses
  SysUtils, Classes;

type
  TOutProcEvent = procedure(Sender: TObject; Item: Integer) of object;

  TNode = class
          private
            FItem  : Integer;
            FLeft,
            FRight : TNode;

          public
            constructor Create(AValue: Integer);
            destructor Destroy; override;

            property Item  : Integer read FItem write FItem;
            property Left  : TNode read FLeft write FLeft;
            property Right : TNode read FRight write FRight;
  				end;

  TBTree = class
  				private
            FRoot 		  : TNode;
            FSentinel   : TNode;
            FCount      : Integer;
            FOnOutProc  : TOutProcEvent;

            function DoSearch(Node: TNode; AValue: Integer): Boolean;
            function FindMax(StartNode: TNode; var Parent: TNode): TNode;

            procedure DoShow(Node: TNode);

            property Root : TNode read FRoot write FRoot;
            property Sentinel : TNode read FSentinel write FSentinel;


            procedure FreeNode(Node: TNode);

          public
            constructor Create();
            destructor  Destroy; override;

            function Empty : Boolean;
            function Search(AValue: Integer): Boolean;
            function DelItem(Item: Integer): Boolean;

            procedure Add(Item: Integer);
            procedure ShowInOrder();
            procedure Clear;

            property Count : Integer read FCount;
            property OnOutProc : TOutProcEvent read FOnOutProc write FOnOutProc;
  				end;

implementation

{ TNode }

constructor TNode.Create(AValue: Integer);
begin
	inherited Create;

  FItem  := AValue;
  FLeft  := nil;
  FRight := nil;
end; (* of TNode.Create *)

destructor TNode.Destroy;
begin

  inherited;
end;

{ TTree }

constructor TBTree.Create;
begin
  inherited Create;

  FSentinel := TNode.Create(0);
  FRoot     := FSentinel;
  FCount    := 0;
  FOnOutProc  := nil;
end;


destructor TBTree.Destroy;
begin
  Clear;
  FSentinel.Free;

  inherited Destroy;
end;


procedure TBTree.Add(Item: Integer);
var
  NewNode, Cur, Parent: TNode;
begin
  NewNode := TNode.Create(Item);

  NewNode.Left  := FSentinel;
  NewNode.Right := FSentinel;

  if (FRoot <> FSentinel) then
  begin
    Cur    := FRoot;
    Parent := nil;

    while (Cur <> FSentinel) do
    begin
      Parent := Cur;

      if (Item < Cur.Item) then
        Cur := Cur.Left
      else
        Cur := Cur.Right;
    end;

    if Item < Parent.Item then
      Parent.Left := NewNode
    else Parent.Right := NewNode;
  end
  else FRoot := NewNode;

  Inc(FCount);
end;


procedure TBTree.DoShow(Node: TNode);
begin
  if (Node <> FSentinel) then
  begin
    DoShow(Node.Left);

    if Assigned(OnOutProc) then
      OnOutProc(self, Node.Item);

    DoShow(Node.Right);
  end;
end;


procedure TBTree.FreeNode(Node: TNode);
var
  RightNode: TNode;
begin
  if (Node <> FSentinel) then
  begin
    FreeNode(Node.Left);

    RightNode := Node.Right;

    Node.Free;

    FreeNode(RightNode);
  end;
end;


procedure TBTree.Clear;
begin
  FreeNode(FRoot);

  FRoot := FSentinel;

  FCount := 0;
end;


function TBTree.FindMax(StartNode: TNode; var Parent: TNode): TNode;
begin
  Parent := StartNode;
  Result := StartNode.Left;

  while (Result.Right <> FSentinel) do
  begin
    Parent := Result;
    Result := Result.Right;
  end;
end;


function TBTree.DelItem(Item: Integer): Boolean;
var
  Node,
  Parent,
  Predecessor,
  PredecessorParent,
  Temp : TNode;

begin
  Result := False;

  Node   := FRoot;
  Parent := FSentinel;

  while ((Node <> FSentinel) and (Node.Item <> Item)) do
  begin
    Parent := Node;

    if (Item < Node.Item) then
      Node := Node.Left
    else
      Node := Node.Right;
  end;

  if (Node <> FSentinel) then
  begin
    if ((Node.Left <> FSentinel) and (Node.Right <> FSentinel)) then
    begin
      Predecessor := FindMax(Node, PredecessorParent);

      Node.Item := Predecessor.Item;

      Node   := Predecessor;
      Parent := PredecessorParent;
    end;

    if (Node.Left <> FSentinel) then
      Temp := Node.Left
    else
      Temp := Node.Right;

    if (Parent = FSentinel) then
      FRoot := Temp
    else if (Parent.Left = Node) then
      Parent.Left := Temp
    else
      Parent.Right := Temp;

    Node.Free;

    Dec(FCount);
    Result := True;
  end;
end;


function TBTree.Empty: Boolean;
begin
  Result := (FCount = 0);
end;


function TBTree.DoSearch(Node: TNode; AValue: Integer): Boolean;
begin
  if (Node.Item <> AValue) then
  begin
    if (AValue < Node.Item) then
      Result := DoSearch(Node.Left, AValue)
    else
    	Result := DoSearch(Node.Right, AValue);
  end
  else
    Result := (Node <> Sentinel);
end;


function TBTree.Search(AValue: Integer): Boolean;
begin
  Sentinel.FItem := AValue;

  Result := DoSearch(Root, AValue);

  Sentinel.FItem := 0;
end;


procedure TBTree.ShowInOrder;
begin
  if (Root <> Sentinel) then
    DoShow(Root)
  else
    Writeln('Liste leer!');
end;

end.
