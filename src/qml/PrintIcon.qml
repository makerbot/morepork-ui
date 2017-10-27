import QtQuick 2.4

PrintIconForm
{
    id: printIcon
    action_mouseArea.onClicked:
    {
        switch(bot.process.stateType)
        {
            case 2:
                //In Printing State
                bot.pausePrint()
                break;
            case 3:
                //In Paused State
                break;
            default:
                break;
        }
    }
}
