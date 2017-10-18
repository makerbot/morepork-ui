import QtQuick 2.4

PrintIconForm
{
    id: printIcon

    action_mouseArea.onClicked:
    {
        switch(current_state)
        {

            case 'printing':
                //----------
                break;

            case 'paused':
                //---------
                break;

            default:
                break;
        }
    }
}
