import QtQuick 2.4
import ProcessStateTypeEnum 1.0

PrintIconForm
{
    id: printIcon
    action_mouseArea.onClicked:
    {
        switch(bot.process.stateType)
        {
            case ProcessStateType.Printing:
                //In Printing State
                bot.pauseResumePrint("suspend")
                break;
            case ProcessStateType.Paused:
                //In Paused State
                bot.pauseResumePrint("resume")
                break;
            default:
                break;
        }
    }
}
