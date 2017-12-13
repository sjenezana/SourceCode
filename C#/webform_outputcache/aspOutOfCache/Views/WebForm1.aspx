<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WebForm1.aspx.cs" Inherits="aspOutOfCache.Views.WebForm1" %>

<%@ Import Namespace="System.Data" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>single web page</title>
</head>
<body>
    <h1>this is single web page</h1>
    <form id="form1" runat="server">
        <div>
            <asp:Label ID="lblInfo" runat="server" Text="Click on the Button to Fill Grid"></asp:Label>
            <br />
            <br />
            <asp:GridView ID="carsGridView" runat="server" Caption="caption" BackColor="White" BorderColor="#E7E7FF" BorderStyle="None" BorderWidth="1px" CellPadding="3" GridLines="Horizontal" >
                <AlternatingRowStyle BackColor="#F7F7F7" />
                <FooterStyle BackColor="#B5C7DE" ForeColor="#4A3C8C" />
                <HeaderStyle BackColor="#4A3C8C" Font-Bold="True" ForeColor="#F7F7F7" />
                <PagerStyle BackColor="#E7E7FF" ForeColor="#4A3C8C" HorizontalAlign="Right" />
                <RowStyle BackColor="#E7E7FF" ForeColor="#4A3C8C" />
                <SelectedRowStyle BackColor="#738A9C" Font-Bold="True" ForeColor="#F7F7F7" />
                <SortedAscendingCellStyle BackColor="#F4F4FD" />
                <SortedAscendingHeaderStyle BackColor="#5A4C9D" />
                <SortedDescendingCellStyle BackColor="#D8D8F0" />
                <SortedDescendingHeaderStyle BackColor="#3E3277" />
            </asp:GridView>
            <br />
            <asp:Button ID="btnFillData" runat="server" Text="Fill Grid" OnClick="btnFillData_Click" />
            <script runat="server">
                protected void btnFillData_Click(object sender, EventArgs e)
                {
                    DataTable t = new DataTable("test");
                    t.Columns.Add("ID");
                    t.Columns.Add("Name");
                    DataRow dataRow = t.NewRow();
                    dataRow[0] = 1;
                    dataRow[1] = "jack";
                    t.Rows.Add(dataRow);
                    DataRow dataRow2 = t.NewRow();
                    dataRow2[0] = 2;
                    dataRow2[1] = "marray";
                    t.Rows.Add(dataRow2);

                    carsGridView.DataSource = t;
                    carsGridView.DataBind();
                }
            </script>
            <br />
        </div>
    </form>
</body>
</html>
