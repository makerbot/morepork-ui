import QtQuick 2.4

PrintIconForm
{
    id: printIcon
    action_mouseArea.onClicked:
    {
        switch(bot.process.stateType)
        {
            case 2:
                //Printing
                bot.pausePrint()
                break;
            case 3:
                //Paused

                break;
            default:
                break;
        }
    }
}
