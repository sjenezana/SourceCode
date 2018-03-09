
<%@ Page Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="ColumnMoving.aspx.cs" Inherits="Columns_ColumnMoving" %>
<asp:Content ContentPlaceHolderID="ControlOptionsTopHolder" runat="server">
    <div class="options">
        <div class="options-item">
            <dx:ASPxCheckBox runat="server" ID="cbProcessColumnMoveOnClient" AutoPostBack="true" Checked="true" Theme="MaterialCompactOrange" Text="Process column moving on client" />
        </div>
        <div class="options-item">
            <dx:ASPxComboBox runat="server" ID="cpColumnMoveMode" AutoPostBack="true" ValueType="DevExpress.Web.GridColumnMoveMode" Theme="MaterialCompactOrange" Caption="Column move mode">
                <Items>
                    <dx:ListEditItem Value="AmongSiblings" Selected="true" />
                    <dx:ListEditItem Value="ThroughHierarchy" />
                </Items>
            </dx:ASPxComboBox>
        </div>
    </div>
</asp:Content>
<asp:Content ContentPlaceHolderID="ContentHolder" runat="server">
    <dx:ASPxGridView ID="Grid" runat="server" DataSourceID="ProductsDataSource" Width="100%">
        <Columns>
            <dx:GridViewDataTextColumn FieldName="ProductName" />
            <dx:GridViewDataComboBoxColumn FieldName="Category.CategoryName" />
            <dx:GridViewDataSpinEditColumn FieldName="UnitPrice">
                <PropertiesSpinEdit DisplayFormatString="c" />
            </dx:GridViewDataSpinEditColumn>
            <dx:GridViewDataSpinEditColumn FieldName="UnitsInStock" />
            <dx:GridViewDataSpinEditColumn FieldName="Total" UnboundType="Integer" UnboundExpression="UnitsInStock*UnitPrice">
                <PropertiesSpinEdit DisplayFormatString="c" />
            </dx:GridViewDataSpinEditColumn>
            <dx:GridViewDataCheckColumn FieldName="Discontinued" Width="80">
                <HeaderStyle HorizontalAlign="Center" />
            </dx:GridViewDataCheckColumn>
        </Columns>
        <FormatConditions>
            <dx:GridViewFormatConditionHighlight FieldName="UnitPrice" Expression="[Discount] > 0" Format="GreenFillWithDarkGreenText" />
            <dx:GridViewFormatConditionTopBottom FieldName="UnitPrice" Rule="TopItems" Threshold="15" Format="BoldText" />
            <dx:GridViewFormatConditionTopBottom FieldName="UnitPrice" Rule="AboveAverage" Format="ItalicText" />
            <dx:GridViewFormatConditionTopBottom FieldName="UnitPrice" Rule="AboveAverage" Format="RedText" />
            <dx:GridViewFormatConditionColorScale FieldName="UnitsInStock" Format="BlueWhiteRed" />
            <dx:GridViewFormatConditionIconSet FieldName="UnitsInStock" Format="Ratings4" />
            <dx:GridViewFormatConditionIconSet FieldName="Total" Format="Arrows5Colored" />
        </FormatConditions>
    </dx:ASPxGridView>
    <div class="Note">
        <b>Note:</b>
        For demonstration purposes, the grid's callback time is intentionally extended.
    </div>
    <ef:EntityDataSource runat="server" ID="ProductsDataSource" Include="Category" ContextTypeName="DevExpress.Web.Demos.NorthwindContext" EntitySetName="Products" />
</asp:Content>



IIF(ISDATE(DATETESTED)=1,DATETESTED,IIF(ISDATE(DATERECEIVED)=1,DATERECEIVED,substring(DATECREATE from 1 for 4)||''/''|| substring(DATECREATE from 5 for 2) ||''/''|| substring(DATECREATE from 7 for 2)))


MOSTRECENT