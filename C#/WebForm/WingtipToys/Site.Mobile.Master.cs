using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WingtipToys
{
    public partial class Site_Mobile : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {

            Page.PreInit += Page_PreInit;
        }
        private void Page_PreInit(object sender, EventArgs e)
        {
            throw new NotImplementedException();
        }
    }
}